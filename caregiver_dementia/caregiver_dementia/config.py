from pathlib import Path
import random
import numpy as np

# =========================
# PATHS
# =========================
BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
RAW_DATA_DIR = DATA_DIR / "raw"
PROCESSED_DATA_DIR = DATA_DIR / "processed"
MODELS_DIR = BASE_DIR / "models"
RESULTS_DIR = BASE_DIR / "results"
FIGURES_DIR = BASE_DIR / "figures"

for d in [RAW_DATA_DIR, PROCESSED_DATA_DIR, MODELS_DIR, RESULTS_DIR, FIGURES_DIR]:
    d.mkdir(exist_ok=True, parents=True)

# =========================
# DATA
# =========================
OASIS_DEMOGRAPHIC_FILE = "oasis_cross-sectional.xlsx"
TARGET_COLUMN = "CDR"

# =========================
# SPLITS
# =========================
TEST_SIZE = 0.20
VALIDATION_SIZE = 0.20
RANDOM_STATE = 42

# =========================
# SEED
# =========================
def set_seeds(seed=42):
    random.seed(seed)
    np.random.seed(seed)

# =========================
# CAREGIVER FEATURE MAP
# Mapping from clinical/OASIS columns → friendly names
# =========================
CAREGIVER_FEATURES = {
    "Age":   "Age (years)",
    "M/F":   "Gender (M=1, F=0)",
    "Educ":  "Years of Education",
    "SES":   "Socioeconomic Status (1=highest, 5=lowest)",
    "MMSE":  "MMSE Score (0-30, 30=perfect)",
}

# =========================
# CDR → Stage mapping
# =========================
# NOTE: In the OASIS cross-sectional dataset, CDR=2 and CDR=3 each have only
# a handful of patients (often just 1-2). Training a 4-way classifier on
# this leads to classes with "support=1" and unreliable/undefined metrics.
# We therefore merge CDR 2 and CDR 3 into a single "Moderate-to-Severe"
# class for the stage classifier — this is still clinically meaningful
# and gives the model enough samples per class to learn a real pattern.
CDR_STAGE_MAP = {
    0.0: ("Normal",            "No dementia detected."),
    0.5: ("Very Mild",         "Very mild cognitive impairment. Questionable dementia."),
    1.0: ("Mild",              "Mild dementia. Some daily living difficulties."),
    2.0: ("Moderate-Severe",   "Moderate to severe dementia. Significant care needs."),
}

# Raw CDR values that get collapsed into the "Moderate-Severe" bucket
MERGE_CDR_VALUES = {3.0: 2.0}
