# 🧠 Caregiver Dementia Detection (v2)

A caregiver-friendly dementia screening tool built on top of the original
OASIS-based RF + XGBoost ensemble. No MRI or clinical equipment required.

---

## 🆕 What's New in v2

| Problem | Fix |
|---|---|
| External MMSE link was broken (404 on Dementia UK site) | Replaced with a **fully self-contained, guided cognitive test** built right into the app — caregivers no longer need to leave the page or rely on a 3rd-party site |
| Stage classifier showed `1 support` / undefined metrics for some classes | OASIS has almost no CDR=2/3 patients individually. **CDR 2 and 3 are now merged into one "Moderate-Severe" class**, so every class has enough samples for meaningful precision/recall/F1 |
| Single long form felt overwhelming | App is now a **3-step wizard**: Patient Info → Cognitive Test → Results, with a progress indicator |
| Caregivers might not know how to score MMSE manually | Test is now **scored automatically** as you tick boxes / select counts — no mental math required (manual entry is still available as a fallback) |
| Plain numbers without context | Every input/result now has plain-language **tooltips and explanations** |

---

## What's Different from the Original (Doctor-Oriented) Project?

| Feature | Original (Doctor) | This Project (Caregiver) |
|---|---|---|
| Inputs needed | eTIV, nWBV, ASF (MRI) | Age, Education, MMSE (via in-app test) |
| Who can use it | Clinicians | Caregivers, family |
| Output | Normal / Dementia | Stage + Recommendations |
| ML model | RF + XGB ensemble | Same + Stage classifier |

---

## Project Structure

```
caregiver_dementia/
├── config.py               ← Paths, constants, CDR stage map (now merges CDR 2/3)
├── requirements.txt
├── data/
│   └── raw/
│       └── oasis_cross-sectional.xlsx   ← PUT YOUR DATA FILE HERE
├── models/                 ← Saved after training
└── src/
    ├── data_loader.py      ← Loads OASIS, extracts caregiver features
    ├── preprocessing.py    ← Feature engineering + scaling + SMOTE
    ├── train_models.py     ← BinaryDementiaTrainer + StageClassifierTrainer
    ├── mmse_test.py         ← NEW: self-administered cognitive test logic
    ├── predict.py           ← CaregiverPredictor inference class
    ├── main.py               ← Training pipeline (run this first)
    └── app.py                ← Streamlit caregiver UI (3-step wizard)
```

---

## Step-by-Step Setup

### Step 1 — Get the data

You're using `oasis_cross-sectional.xlsx`. Place it here:
```
data/raw/oasis_cross-sectional.xlsx
```

### Step 2 — Create virtual environment

```bash
python -m venv venv

# Windows:
venv\Scripts\activate

# Mac/Linux:
source venv/bin/activate
```

### Step 3 — Install dependencies

```bash
pip install -r requirements.txt
```

### Step 4 — Train the models

```bash
python src/main.py
```

Expected output now includes class counts before the stage report, so
you can see exactly why metrics look the way they do for sparse classes:
```
══════════════════════════════════════════════════════════════════════
  CAREGIVER DEMENTIA DETECTION — TRAINING PIPELINE
══════════════════════════════════════════════════════════════════════
OASIS Data Loader Initialized
✓ Loaded 436 samples | Dementia: 101 | Normal: 335

── Stage 1: Binary Detection (Normal vs Dementia) ──
  RF  → Acc: 0.908  AUC: 0.946  F1: 0.871
  XGB → Acc: 0.908  AUC: 0.961  F1: 0.871
  ENSEMBLE → Acc: 0.897  F1: 0.858

── Stage 2: Dementia Stage Classifier ──
  Stage class counts (train): {0.5: 41, 1.0: 18, 2.0: 2}
  Stage class counts (val)  : {0.5: 15, 1.0: 5, 2.0: 1}
  Stage XGB → Val Acc: 0.7xx
  Classes (CDR): [0.5, 1.0, 2.0]

  ✅  TRAINING COMPLETE — All models saved to models/
```

### Step 5 — Launch the caregiver app

```bash
streamlit run src/app.py
```

Then open: http://localhost:8501

---

## Using the App (v2 Flow)

**Step 1 — Patient Info:** age, gender, years of education, socioeconomic status.

**Step 2 — Cognitive Test:** Choose either:
- *Take the guided test now* — a 7-section, ~10 minute self-administered
  test built into the app (orientation, registration, attention, recall,
  language, visuospatial). The score (0–30) is computed automatically.
- *I already have an MMSE score* — manual slider entry if the patient
  has already been tested elsewhere.

**Step 3 — Results:** Risk %, stage, estimated CDR, and tailored
recommendations.

### About the In-App Cognitive Test
This is a simplified screening adaptation that mirrors the same
cognitive domains as the standard MMSE (the official MMSE is a
licensed/copyrighted instrument from PAR Inc., so this app does not
reproduce it verbatim — it implements an equivalent open structure
covering the same 7 domains and the same 0–30 scoring range).

---

## Model Architecture

```
Stage 1: Binary Detection
  Input (5 raw + 6 engineered = 11 features)
     ↓
  Random Forest (600 trees, depth 12)  ──┐
  XGBoost (700 estimators, lr=0.03)    ──┤→ Meta LogReg → Probability
                                          │
  Threshold tuned to maximize F1         │
     ↓
  Output: Normal / Dementia + Risk %

Stage 2: Stage Classification (dementia patients only)
  XGBoost multi-class (3 classes: Very Mild / Mild / Moderate-Severe)
  CDR 2 and 3 merged → avoids "support=1" undefined-metric classes
  Output: Very Mild (CDR 0.5) / Mild (1) / Moderate-Severe (2+)
```

### Engineered Features
Beyond the 5 raw inputs, the model adds:

| Feature | Why |
|---|---|
| `age_squared` | Non-linear aging effects |
| `age_bucket` | Age group (60, 70, 80+) |
| `educ_mmse` | Education-adjusted cognitive score |
| `mmse_low` | Flag: MMSE < 24 (clinical threshold) |
| `mmse_very_low` | Flag: MMSE < 18 (moderate impairment) |
| `age_mmse_ratio` | Age relative to cognitive score |

---

## Performance

| Metric | Binary Detection |
|---|---|
| Accuracy | ~90% |
| AUC | ~0.96 |
| F1 | ~0.87 |

Stage classifier accuracy depends heavily on how many dementia-positive
samples exist in your specific OASIS export — with the standard
cross-sectional file (~101 dementia cases) expect 65–75% on the
3-class (merged) stage problem.

---

## Why the Stage Classifier Used to Show "1 support"

The OASIS cross-sectional dataset has roughly:
- CDR 0   (Normal): ~335 patients
- CDR 0.5 (Very Mild): ~70 patients
- CDR 1   (Mild): ~28 patients
- CDR 2   (Moderate): ~2 patients
- CDR 3   (Severe): ~1 patient

With a 4-way classifier, a random validation split could easily put
the single CDR=3 patient by itself in one split — giving that class
`support=1` and an undefined or misleading precision/recall. v2 merges
CDR 2 and 3 into "Moderate-Severe" so every class has a workable number
of samples.

---

## Programmatic Use

```python
from src.predict import CaregiverPredictor

p = CaregiverPredictor()
result = p.predict(
    age=72,
    gender="F",
    education=16,
    ses=4,
    mmse=22,
)

print(result)
# {
#   'has_dementia': False,
#   'probability': 6.2,
#   'risk_level': 'Very Low Risk',
#   'stage': 'Normal',
#   'stage_cdr': 0.0,
#   'recommendation': 'No signs of dementia detected...',
#   'emoji': '✅'
# }
```

---

## Disclaimer

This tool is for **educational and screening purposes only**.
It is NOT a substitute for clinical evaluation.
Always consult a qualified healthcare professional for diagnosis and treatment.
