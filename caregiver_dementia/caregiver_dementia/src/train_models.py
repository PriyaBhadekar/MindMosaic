import numpy as np
import pandas as pd
import joblib
import sys
from pathlib import Path

from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, roc_auc_score, f1_score, classification_report
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBClassifier

sys.path.append(str(Path(__file__).parent.parent))
import config


# ═══════════════════════════════════════════════════════════════════
#  STAGE 1 — Binary Detection  (Normal vs Dementia)
# ═══════════════════════════════════════════════════════════════════

class BinaryDementiaTrainer:
    """RF + XGB stacking ensemble (same architecture as original project)."""

    def __init__(self):
        self.models = {}
        self.thresholds = {}
        print("\n── Stage 1: Binary Detection (Normal vs Dementia) ──")

    # ── Random Forest ─────────────────────────────────────────────
    def train_random_forest(self, X_train, y_train, X_val, y_val):
        rf = RandomForestClassifier(
            n_estimators=600,
            max_depth=12,
            min_samples_split=3,
            min_samples_leaf=2,
            class_weight="balanced_subsample",
            random_state=config.RANDOM_STATE,
            n_jobs=-1,
        )
        rf.fit(X_train, y_train)

        probs = rf.predict_proba(X_val)[:, 1]
        t = self._best_threshold(y_val, probs)
        preds = (probs >= t).astype(int)

        print(f"  RF  → Acc: {accuracy_score(y_val, preds):.3f}  "
              f"AUC: {roc_auc_score(y_val, probs):.3f}  "
              f"F1: {f1_score(y_val, preds):.3f}")

        self.models["rf"] = rf
        self.thresholds["rf"] = t

    # ── XGBoost ───────────────────────────────────────────────────
    def train_xgboost(self, X_train, y_train, X_val, y_val):
        pos_weight = (y_train == 0).sum() / (y_train == 1).sum()

        xgb = XGBClassifier(
            n_estimators=700,
            max_depth=4,
            learning_rate=0.03,
            subsample=0.85,
            colsample_bytree=0.85,
            scale_pos_weight=pos_weight,
            objective="binary:logistic",
            eval_metric="auc",
            random_state=config.RANDOM_STATE,
            n_jobs=-1,
            verbosity=0,
        )
        xgb.fit(X_train, y_train)

        probs = xgb.predict_proba(X_val)[:, 1]
        t = self._best_threshold(y_val, probs)
        preds = (probs >= t).astype(int)

        print(f"  XGB → Acc: {accuracy_score(y_val, preds):.3f}  "
              f"AUC: {roc_auc_score(y_val, probs):.3f}  "
              f"F1: {f1_score(y_val, preds):.3f}")

        self.models["xgb"] = xgb
        self.thresholds["xgb"] = t

    # ── Stacking Ensemble (meta LogReg) ───────────────────────────
    def train_ensemble(self, X_val, y_val):
        rf_p  = self.models["rf"].predict_proba(X_val)[:, 1]
        xgb_p = self.models["xgb"].predict_proba(X_val)[:, 1]

        meta_X = np.column_stack([rf_p, xgb_p])
        meta = LogisticRegression(random_state=config.RANDOM_STATE)
        meta.fit(meta_X, y_val)

        ens_p = meta.predict_proba(meta_X)[:, 1]
        t = self._best_threshold(y_val, ens_p)
        preds = (ens_p >= t).astype(int)

        print(f"  ENSEMBLE → Acc: {accuracy_score(y_val, preds):.3f}  "
              f"F1: {f1_score(y_val, preds):.3f}")

        self.models["meta"] = meta
        self.thresholds["ensemble"] = t

    def evaluate_on_test(self, X_test, y_test):
        rf_p  = self.models["rf"].predict_proba(X_test)[:, 1]
        xgb_p = self.models["xgb"].predict_proba(X_test)[:, 1]
        meta_X = np.column_stack([rf_p, xgb_p])
        ens_p = self.models["meta"].predict_proba(meta_X)[:, 1]

        t = self.thresholds["ensemble"]
        preds = (ens_p >= t).astype(int)

        print(f"\n  TEST SET RESULTS:")
        print(f"  Accuracy : {accuracy_score(y_test, preds):.3f}")
        print(f"  AUC      : {roc_auc_score(y_test, ens_p):.3f}")
        print(f"  F1       : {f1_score(y_test, preds):.3f}")
        print(classification_report(y_test, preds,
                                    target_names=["Normal", "Dementia"]))

    def save(self):
        joblib.dump(self.models["rf"],   config.MODELS_DIR / "binary_rf.pkl")
        joblib.dump(self.models["xgb"],  config.MODELS_DIR / "binary_xgb.pkl")
        joblib.dump(self.models["meta"], config.MODELS_DIR / "binary_meta.pkl")
        joblib.dump(self.thresholds,     config.MODELS_DIR / "binary_thresholds.pkl")
        print("  ✓ Binary models saved")

    @staticmethod
    def _best_threshold(y_true, probs):
        best_f1, best_t = 0, 0.5
        for t in np.arange(0.2, 0.8, 0.01):
            f1 = f1_score(y_true, (probs >= t).astype(int), zero_division=0)
            if f1 > best_f1:
                best_f1, best_t = f1, t
        return best_t


# ═══════════════════════════════════════════════════════════════════
#  STAGE 2 — Dementia Stage Classifier  (CDR staging)
#  Only trained & applied on samples where binary == 1
# ═══════════════════════════════════════════════════════════════════

class StageClassifierTrainer:
    """
    Multi-class classifier for CDR stage among dementia-positive patients.

    IMPORTANT — class merging:
    OASIS cross-sectional has very few CDR=2 and almost no CDR=3 patients
    (often single digits combined). Keeping them as separate classes
    produces classes with support=1, which makes precision/recall/F1
    undefined or meaningless for that class (this is the "2 class and
    1 support" issue). We merge CDR 2 and 3 into one "Moderate-Severe"
    class (config.MERGE_CDR_VALUES) so every class has enough samples
    for the metrics to mean something.

    Final classes: 0.5 (Very Mild), 1.0 (Mild), 2.0 (Moderate-Severe)
    """

    def __init__(self):
        self.model = None
        self.le = LabelEncoder()
        print("\n── Stage 2: Dementia Stage Classifier ──")

    @staticmethod
    def _merge_sparse_classes(y):
        y = y.copy()
        for old_val, new_val in config.MERGE_CDR_VALUES.items():
            y = y.replace(old_val, new_val)
        return y

    def train(self, X_train, y_stg_train, X_val, y_stg_val):
        y_stg_train = self._merge_sparse_classes(y_stg_train)
        y_stg_val   = self._merge_sparse_classes(y_stg_val)

        mask_train = y_stg_train > 0
        mask_val   = y_stg_val > 0

        if mask_train.sum() < 10:
            print("  [!] Too few dementia samples for stage classifier. Skipping.")
            return

        Xt = X_train[mask_train]
        yt = y_stg_train[mask_train]
        Xv = X_val[mask_val]
        yv = y_stg_val[mask_val]

        print(f"  Stage class counts (train): {yt.value_counts().to_dict()}")
        print(f"  Stage class counts (val)  : {yv.value_counts().to_dict()}")

        self.le.fit(pd.concat([yt, yv]))
        yt_enc = self.le.transform(yt)
        yv_enc = self.le.transform(yv)

        n_classes = len(self.le.classes_)

        xgb = XGBClassifier(
            n_estimators=400,
            max_depth=3,
            learning_rate=0.05,
            subsample=0.8,
            colsample_bytree=0.8,
            objective="multi:softprob",
            num_class=n_classes,
            eval_metric="mlogloss",
            random_state=config.RANDOM_STATE,
            n_jobs=-1,
            verbosity=0,
        )
        xgb.fit(Xt, yt_enc)

        val_preds = xgb.predict(Xv)
        acc = accuracy_score(yv_enc, val_preds)
        print(f"  Stage XGB → Val Acc: {acc:.3f}")
        print(f"  Classes (CDR): {list(self.le.classes_)}")

        all_labels = list(range(n_classes))
        print(classification_report(
            yv_enc, val_preds,
            labels=all_labels,
            target_names=[str(c) for c in self.le.classes_],
            zero_division=0,
        ))

        self.model = xgb

    def save(self):
        if self.model is None:
            return
        joblib.dump(self.model, config.MODELS_DIR / "stage_xgb.pkl")
        joblib.dump(self.le,    config.MODELS_DIR / "stage_label_encoder.pkl")
        print("  ✓ Stage model saved")
