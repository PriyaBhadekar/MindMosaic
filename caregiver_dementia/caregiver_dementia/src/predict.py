"""
predict.py
──────────
Inference module for the caregiver-facing dementia detection system.

Usage (programmatic):
    from src.predict import CaregiverPredictor
    p = CaregiverPredictor()
    result = p.predict(age=72, gender="F", education=16, ses=4, mmse=22)
    print(result)
"""

import numpy as np
import pandas as pd
import joblib
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
import config


CDR_LABELS = {
    0.0: ("Normal",          "✅"),
    0.5: ("Very Mild",       "🟡"),
    1.0: ("Mild",            "🟠"),
    2.0: ("Moderate-Severe", "🔴"),
}

RECOMMENDATIONS = {
    "Normal": (
        "No signs of dementia detected.\n"
        "• Continue regular cognitive assessments every 6–12 months.\n"
        "• Encourage physical exercise, social engagement, and mental stimulation.\n"
        "• Maintain a healthy diet and manage cardiovascular risk factors."
    ),
    "Very Mild": (
        "Very mild cognitive changes detected (CDR 0.5).\n"
        "• Schedule a formal neurological evaluation soon.\n"
        "• Monitor for memory lapses, confusion, or personality changes.\n"
        "• Consider cognitive stimulation activities and structured routines.\n"
        "• Review medications with the patient's doctor."
    ),
    "Mild": (
        "Mild dementia detected (CDR 1).\n"
        "• Seek specialist evaluation (neurologist or geriatrician) promptly.\n"
        "• Begin safety planning at home (stove, driving, finances).\n"
        "• Explore support groups for both patient and caregiver.\n"
        "• Consider legal/financial planning while patient can participate."
    ),
    "Moderate-Severe": (
        "Moderate to severe dementia detected (CDR 2+).\n"
        "• Patient likely requires substantial or full-time daily support.\n"
        "• Consult a specialist about residential or in-home professional care.\n"
        "• Ensure home safety: remove fall hazards, secure medications.\n"
        "• Explore respite care for the caregiver and contact local dementia\n"
        "  support services (e.g. Alzheimer's Association).\n"
        "• Focus on comfort, dignity, and quality of life."
    ),
}


class CaregiverPredictor:
    """
    Loads trained models and produces a caregiver-friendly prediction.

    Parameters caregivers need to provide:
      age        (int)   : patient's age in years
      gender     (str)   : 'M' or 'F'
      education  (int)   : years of formal education
      ses        (int)   : socioeconomic status 1–5 (1=highest, 5=lowest)
      mmse       (int)   : MMSE score 0–30 (can be estimated with a simple test)
    """

    def __init__(self):
        models_dir = config.MODELS_DIR
        self.rf    = joblib.load(models_dir / "binary_rf.pkl")
        self.xgb   = joblib.load(models_dir / "binary_xgb.pkl")
        self.meta  = joblib.load(models_dir / "binary_meta.pkl")
        self.thresholds = joblib.load(models_dir / "binary_thresholds.pkl")
        self.scaler = joblib.load(models_dir / "scaler.pkl")
        self.feature_names = joblib.load(models_dir / "feature_names.pkl")

        # Stage model (optional – may not exist if too few samples)
        stage_path = models_dir / "stage_xgb.pkl"
        le_path    = models_dir / "stage_label_encoder.pkl"
        if stage_path.exists() and le_path.exists():
            self.stage_model = joblib.load(stage_path)
            self.stage_le    = joblib.load(le_path)
        else:
            self.stage_model = None
            self.stage_le    = None

    def _build_features(self, age, gender, education, ses, mmse):
        gender_enc = 1 if str(gender).upper() == "M" else 0

        raw = {
            "M/F":  gender_enc,
            "Age":  age,
            "Educ": education,
            "SES":  ses,
            "MMSE": mmse,
        }
        X = pd.DataFrame([raw])

        # Engineered features (must match preprocessing.py)
        X["age_squared"]    = X["Age"] ** 2
        X["age_bucket"]     = int(np.digitize(age, [60, 70, 80]) )
        X["educ_mmse"]      = X["Educ"] * X["MMSE"]
        X["mmse_low"]       = int(mmse < 24)
        X["mmse_very_low"]  = int(mmse < 18)
        X["age_mmse_ratio"] = age / (mmse + 1)

        # Align to training feature order
        for col in self.feature_names:
            if col not in X.columns:
                X[col] = 0
        X = X[self.feature_names]

        # Scale
        X_scaled = pd.DataFrame(
            self.scaler.transform(X),
            columns=self.feature_names,
        )
        return X_scaled

    def predict(self, age, gender, education, ses, mmse):
        """
        Returns a dict with:
          has_dementia  : bool
          probability   : float (0–1)
          risk_level    : str
          stage         : str (if dementia detected)
          stage_cdr     : float
          recommendation: str
          emoji         : str
        """
        X = self._build_features(age, gender, education, ses, mmse)

        # ── Binary prediction ──────────────────────────────────────
        rf_p  = self.rf.predict_proba(X)[:, 1][0]
        xgb_p = self.xgb.predict_proba(X)[:, 1][0]
        meta_X = np.array([[rf_p, xgb_p]])
        prob  = self.meta.predict_proba(meta_X)[:, 1][0]

        threshold = self.thresholds.get("ensemble", 0.5)
        has_dementia = prob >= threshold

        # ── Risk level ────────────────────────────────────────────
        if prob < 0.20:
            risk_level = "Very Low Risk"
        elif prob < 0.40:
            risk_level = "Low Risk"
        elif prob < 0.60:
            risk_level = "Moderate Risk"
        elif prob < 0.80:
            risk_level = "High Risk"
        else:
            risk_level = "Very High Risk"

        # ── Stage prediction ───────────────────────────────────────
        if has_dementia and self.stage_model is not None:
            stage_enc = self.stage_model.predict(X)[0]
            stage_cdr = float(self.stage_le.inverse_transform([stage_enc])[0])
        else:
            stage_cdr = 0.0

        stage_name, emoji = CDR_LABELS.get(stage_cdr, ("Unknown", "❓"))
        rec = RECOMMENDATIONS.get(stage_name, "Please consult a healthcare professional.")

        return {
            "has_dementia":   bool(has_dementia),
            "probability":    round(float(prob) * 100, 1),
            "risk_level":     risk_level,
            "stage":          stage_name,
            "stage_cdr":      stage_cdr,
            "recommendation": rec,
            "emoji":          emoji,
        }
