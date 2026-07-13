import pandas as pd
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
import config


class OASISDataLoader:
    """
    Loads the OASIS cross-sectional dataset.

    Outputs:
      X  – feature matrix (caregiver-friendly columns only)
      y_binary – 0=No Dementia, 1=Dementia  (CDR > 0)
      y_stage  – CDR numeric for stage classification (0, 0.5, 1, 2, 3)
    """

    def __init__(self):
        print("OASIS Data Loader Initialized")

    def load_data(self):
        data_path = config.RAW_DATA_DIR / config.OASIS_DEMOGRAPHIC_FILE

        if not data_path.exists():
            raise FileNotFoundError(
                f"\n[!] Data file not found at:\n    {data_path}\n"
                f"    Please place 'oasis_cross-sectional.xlsx' in the data/raw/ folder.\n"
                f"    Download: https://www.oasis-brains.org/"
            )

        demo = pd.read_excel(data_path)

        # ── Validate required columns ──────────────────────────────────
        required = ["Age", "Educ", "MMSE", "CDR"]
        for col in required:
            if col not in demo.columns:
                raise ValueError(f"Missing required column: {col}")

        # ── Targets ───────────────────────────────────────────────────
        # Binary: has dementia or not
        y_binary = (demo["CDR"] > 0).astype(int)

        # Stage: use CDR directly; we bucket 2 & 3 together if needed
        y_stage = demo["CDR"].copy()

        # ── Caregiver-friendly features only ─────────────────────────
        caregiver_cols = ["M/F", "Age", "Educ", "SES", "MMSE"]
        # Some OASIS versions use "Gender" instead of "M/F"
        if "M/F" not in demo.columns and "Gender" in demo.columns:
            demo = demo.rename(columns={"Gender": "M/F"})

        available = [c for c in caregiver_cols if c in demo.columns]
        X = demo[available].copy()

        # ── Gender encoding ───────────────────────────────────────────
        if "M/F" in X.columns:
            X["M/F"] = X["M/F"].map({"M": 1, "F": 0}).fillna(X["M/F"])

        # ── Fill missing values ───────────────────────────────────────
        for col in X.columns:
            X[col] = pd.to_numeric(X[col], errors="coerce")
            X[col] = X[col].fillna(X[col].median())

        print(f"✓ Loaded {len(X)} samples | "
              f"Dementia: {y_binary.sum()} | Normal: {(y_binary==0).sum()}")
        print(f"  Features used: {list(X.columns)}")
        return X, y_binary, y_stage
