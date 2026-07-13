import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from imblearn.over_sampling import SMOTE
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
import config


class DataPreprocessor:

    def __init__(self):
        self.scaler = StandardScaler()
        self.feature_names = None
        print("Data Preprocessor Initialized")

    def split_data(self, X, y_binary, y_stage):
        """Split into train / val / test keeping both target arrays aligned."""

        X_temp, X_test, y_bin_temp, y_bin_test, y_stg_temp, y_stg_test = \
            train_test_split(
                X, y_binary, y_stage,
                test_size=config.TEST_SIZE,
                stratify=y_binary,
                random_state=config.RANDOM_STATE,
            )

        val_size = config.VALIDATION_SIZE / (1 - config.TEST_SIZE)

        X_train, X_val, y_bin_train, y_bin_val, y_stg_train, y_stg_val = \
            train_test_split(
                X_temp, y_bin_temp, y_stg_temp,
                test_size=val_size,
                stratify=y_bin_temp,
                random_state=config.RANDOM_STATE,
            )

        print(f"✓ Split → Train:{len(X_train)}  Val:{len(X_val)}  Test:{len(X_test)}")
        return (X_train, X_val, X_test,
                y_bin_train, y_bin_val, y_bin_test,
                y_stg_train, y_stg_val, y_stg_test)

    def engineer_features(self, X):
        """Add derived caregiver-observable features."""
        X = X.copy()

        if "Age" in X.columns:
            X["age_squared"] = X["Age"] ** 2
            X["age_bucket"] = pd.cut(
                X["Age"],
                bins=[0, 60, 70, 80, 120],
                labels=[0, 1, 2, 3],
            ).astype(int)

        if "Educ" in X.columns and "MMSE" in X.columns:
            # MMSE adjusted for education level – a known clinical proxy
            X["educ_mmse"] = X["Educ"] * X["MMSE"]

        if "MMSE" in X.columns:
            # Low MMSE is a strong dementia signal
            X["mmse_low"] = (X["MMSE"] < 24).astype(int)
            X["mmse_very_low"] = (X["MMSE"] < 18).astype(int)

        if "Age" in X.columns and "MMSE" in X.columns:
            X["age_mmse_ratio"] = X["Age"] / (X["MMSE"] + 1)

        return X

    def scale_features(self, X_train, X_val, X_test):
        self.scaler.fit(X_train)
        self.feature_names = list(X_train.columns)

        def _t(df):
            return pd.DataFrame(
                self.scaler.transform(df),
                columns=df.columns,
                index=df.index,
            )

        return _t(X_train), _t(X_val), _t(X_test)

    def handle_class_imbalance(self, X_train, y_train):
        smote = SMOTE(random_state=config.RANDOM_STATE)
        X_bal, y_bal = smote.fit_resample(X_train, y_train)
        X_bal = pd.DataFrame(X_bal, columns=X_train.columns)
        print(f"✓ SMOTE applied → Balanced training: {len(X_bal)} samples")
        return X_bal, y_bal
