"""
main.py  –  Caregiver Dementia Detection Training Pipeline
───────────────────────────────────────────────────────────
Run with:
    python src/main.py

Trains:
  1. RF + XGB stacking ensemble  (binary: Normal vs Dementia)
  2. XGB multi-class             (stage: CDR 0.5 / 1 / 2 / 3)

Saves all models, scaler, and feature names to models/
"""

import sys
import joblib
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from data_loader import OASISDataLoader
from preprocessing import DataPreprocessor
from train_models import BinaryDementiaTrainer, StageClassifierTrainer
import config


def main():
    print("=" * 70)
    print("  CAREGIVER DEMENTIA DETECTION — TRAINING PIPELINE")
    print("=" * 70)

    config.set_seeds()

    # ── 1. Load data ───────────────────────────────────────────────
    loader = OASISDataLoader()
    X, y_binary, y_stage = loader.load_data()

    # ── 2. Split ───────────────────────────────────────────────────
    prep = DataPreprocessor()
    (X_train, X_val, X_test,
     y_bin_train, y_bin_val, y_bin_test,
     y_stg_train, y_stg_val, y_stg_test) = prep.split_data(X, y_binary, y_stage)

    # ── 3. Feature engineering ─────────────────────────────────────
    X_train = prep.engineer_features(X_train)
    X_val   = prep.engineer_features(X_val)
    X_test  = prep.engineer_features(X_test)

    print(f"\n  Feature names ({len(X_train.columns)}):")
    print(f"  {list(X_train.columns)}")

    # ── 4. Scale ───────────────────────────────────────────────────
    X_train, X_val, X_test = prep.scale_features(X_train, X_val, X_test)

    # Save scaler + feature names for inference
    joblib.dump(prep.scaler,       config.MODELS_DIR / "scaler.pkl")
    joblib.dump(prep.feature_names, config.MODELS_DIR / "feature_names.pkl")
    print("  ✓ Scaler and feature names saved")

    # ── 5. Class imbalance (binary only) ──────────────────────────
    X_train_bal, y_bin_train_bal = prep.handle_class_imbalance(X_train, y_bin_train)

    # ── 6. Binary detection model ──────────────────────────────────
    binary_trainer = BinaryDementiaTrainer()
    binary_trainer.train_random_forest(X_train_bal, y_bin_train_bal, X_val, y_bin_val)
    binary_trainer.train_xgboost(X_train_bal, y_bin_train_bal, X_val, y_bin_val)
    binary_trainer.train_ensemble(X_val, y_bin_val)
    binary_trainer.evaluate_on_test(X_test, y_bin_test)
    binary_trainer.save()

    # ── 7. Stage classifier ────────────────────────────────────────
    stage_trainer = StageClassifierTrainer()
    stage_trainer.train(X_train, y_stg_train, X_val, y_stg_val)
    stage_trainer.save()

    print("\n" + "=" * 70)
    print("  ✅  TRAINING COMPLETE — All models saved to models/")
    print("=" * 70)
    print("\nNext step: python src/app.py   (to launch the caregiver app)")


if __name__ == "__main__":
    main()
