"""
app.py  –  Caregiver-Friendly Dementia Detection App  (v2)
─────────────────────────────────────────────────────────────
Run with:
    streamlit run src/app.py

What's new in v2:
  • Built-in, guided, self-administered cognitive test (no broken
    external link — replaces the MMSE link with an in-app wizard)
  • Step-by-step flow (Patient Info → Cognitive Test → Results)
  • Plain-language explanations throughout, tooltips on every field
  • Score auto-computed from the test instead of a bare slider
  • Manual "I already have an MMSE score" option kept for flexibility
  • Clearer, friendlier results screen with stage-specific colour coding
"""

import sys
from pathlib import Path
import streamlit as st

sys.path.append(str(Path(__file__).parent.parent))
import mmse_test as mt
# ── Page config ────────────────────────────────────────────────────
st.set_page_config(
    page_title="Dementia Care Screen",
    page_icon="🧠",
    layout="centered",
)

# ── Custom CSS ─────────────────────────────────────────────────────
st.markdown("""
<style>
    .stButton>button {
        width: 100%;
        padding: 14px;
        font-size: 17px;
        background: linear-gradient(135deg, #6C63FF, #48B7A4);
        color: white;
        border: none;
        border-radius: 12px;
    }
    .result-card {
        background: white;
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        margin-top: 24px;
    }
    .stage-label { font-size: 28px; font-weight: 700; }
    .info-box {
        background: #f0f4ff;
        border-left: 4px solid #6C63FF;
        padding: 14px 18px;
        border-radius: 8px;
        margin-bottom: 20px;
        font-size: 15px;
    }
    .step-pill {
        display:inline-block; padding:6px 14px; border-radius:20px;
        font-size:13px; font-weight:600; margin-right:6px;
    }
    .step-active { background:#6C63FF; color:white; }
    .step-inactive { background:#e0e0e0; color:#777; }
    .section-card {
        background: rgba(255,255,255,0.03);
        border: 1px solid rgba(255,255,255,0.08);
        border-radius: 12px;
        padding: 18px 20px;
        margin-bottom: 16px;
    }
</style>
""", unsafe_allow_html=True)

# ── Header ─────────────────────────────────────────────────────────
st.markdown("# 🧠 Dementia Care Screen")
st.markdown("#### AI-Powered Caregiver Assessment Tool")
st.markdown("---")

# ── Session state setup ────────────────────────────────────────────
if "step" not in st.session_state:
    st.session_state.step = 1
if "patient" not in st.session_state:
    st.session_state.patient = {}
if "mmse_word_set" not in st.session_state:
    st.session_state.mmse_word_set = mt.pick_word_set()
if "mmse_score" not in st.session_state:
    st.session_state.mmse_score = None

# ── Step indicator ─────────────────────────────────────────────────
steps = ["1. Patient Info", "2. Cognitive Test", "3. Results"]
pill_html = ""
for i, label in enumerate(steps, start=1):
    css = "step-active" if i == st.session_state.step else "step-inactive"
    pill_html += f'<span class="step-pill {css}">{label}</span>'
st.markdown(pill_html, unsafe_allow_html=True)
st.write("")


# ── Lazy-load predictor ────────────────────────────────────────────
@st.cache_resource
def load_predictor():
    try:
        from predict import CaregiverPredictor
        return CaregiverPredictor(), None
    except Exception as e:
        return None, str(e)


predictor, load_error = load_predictor()

if load_error:
    st.error(f"⚠️ Could not load models: {load_error}")
    st.info("Please run `python src/main.py` first to train and save the models.")
    st.stop()


# ═══════════════════════════════════════════════════════════════════
# STEP 1 — Patient Info
# ═══════════════════════════════════════════════════════════════════
if st.session_state.step == 1:

    st.markdown("""
    <div class="info-box">
        ℹ️ Answer a few basic questions about your loved one.
        No medical equipment needed.
    </div>
    """, unsafe_allow_html=True)

    st.markdown("### 👤 About the Patient")

    col1, col2 = st.columns(2)
    with col1:
        age = st.number_input("Age (years)", min_value=18, max_value=110,
                               value=st.session_state.patient.get("age", 72), step=1)
    with col2:
        gender = st.selectbox("Gender", options=["Female", "Male"],
                               index=0 if st.session_state.patient.get("gender", "Female") == "Female" else 1)

    col3, col4 = st.columns(2)
    with col3:
        education = st.number_input(
            "Years of formal education",
            min_value=0, max_value=25,
            value=st.session_state.patient.get("education", 12), step=1,
            help="e.g. 12 = finished high school, 16 = college graduate"
        )
    with col4:
        ses = st.selectbox(
            "Socioeconomic status",
            options=[1, 2, 3, 4, 5],
            index=[1, 2, 3, 4, 5].index(st.session_state.patient.get("ses", 3)),
            format_func=lambda x: {
                1: "1 – Highest", 2: "2 – Upper Middle", 3: "3 – Middle",
                4: "4 – Lower Middle", 5: "5 – Lowest",
            }[x],
            help="A rough estimate is fine — 1 = most resources/income, 5 = least"
        )

    st.write("")
    if st.button("Next: Cognitive Test  →"):
        st.session_state.patient = {
            "age": age, "gender": gender,
            "education": education, "ses": ses,
        }
        st.session_state.step = 2
        st.rerun()


# ═══════════════════════════════════════════════════════════════════
# STEP 2 — Cognitive Test (replaces broken external MMSE link)
# ═══════════════════════════════════════════════════════════════════
elif st.session_state.step == 2:

    st.markdown("### 🧩 Cognitive Assessment")

    st.markdown("""
    <div class="info-box">
        This in-app test takes about <b>10 minutes</b>. Read each instruction
        aloud to the patient exactly as written, and tick the boxes for what
        they answer correctly. No external website needed.
    </div>
    """, unsafe_allow_html=True)

    mode = st.radio(
        "How would you like to provide the cognitive score?",
        options=["Take the guided test now", "I already have an MMSE score"],
        horizontal=False,
    )

    # ── Option B: manual entry ──────────────────────────────────────
    if mode == "I already have an MMSE score":
        st.write("")
        manual_score = st.slider(
            "MMSE Score (0 = worst, 30 = perfect)",
            min_value=0, max_value=30, value=26,
            help="27–30 Normal · 21–26 Mild · 11–20 Moderate · ≤10 Severe"
        )
        st.session_state.mmse_score = manual_score

        st.write("")
        c1, c2 = st.columns(2)
        with c1:
            if st.button("← Back"):
                st.session_state.step = 1
                st.rerun()
        with c2:
            if st.button("Next: See Results  →"):
                st.session_state.step = 3
                st.rerun()

    # ── Option A: guided in-app test ─────────────────────────────────
    else:
        today = mt.get_today_questions()
        words = st.session_state.mmse_word_set

        with st.form("mmse_form"):

            # 1. Orientation to time
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown("**1. Orientation to Time** — Ask the patient:")
            ot_year = st.checkbox(f"What year is it? (correct: {today['year']})")
            ot_season = st.checkbox(f"What season is it? (correct: {today['season']})")
            ot_month = st.checkbox(f"What month is it? (correct: {today['month']})")
            ot_day = st.checkbox(f"What day of the week is it? (correct: {today['day_of_week']})")
            ot_date = st.checkbox(f"What is today's date? (correct: {today['date']})")
            st.markdown('</div>', unsafe_allow_html=True)

            # 2. Orientation to place
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown("**2. Orientation to Place** — Ask the patient to name:")
            op_country = st.checkbox("Country they are in")
            op_state = st.checkbox("State / Province")
            op_city = st.checkbox("City / Town")
            op_building = st.checkbox("Building or place they are in (e.g. 'home', 'clinic')")
            op_floor = st.checkbox("Floor or room they are in")
            st.markdown('</div>', unsafe_allow_html=True)

            # 3. Registration
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown(
                f"**3. Registration** — Say these 3 words clearly, 1 second apart: "
                f"**{words[0]}, {words[1]}, {words[2]}**. Ask the patient to repeat them "
                f"back immediately. *(Remember these — you'll ask again in Step 5.)*"
            )
            reg_count = st.radio("How many words did they repeat correctly?",
                                  options=[0, 1, 2, 3], horizontal=True, key="reg")
            st.markdown('</div>', unsafe_allow_html=True)

            # 4. Attention
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown(
                "**4. Attention & Calculation** — Ask the patient to count backward "
                "from 100 by 7s (100 → 93 → 86 → 79 → 72). "
                "If they can't, ask them to spell 'WORLD' backwards instead."
            )
            attn_count = st.radio("How many correct steps did they get (out of 5)?",
                                   options=[0, 1, 2, 3, 4, 5], horizontal=True, key="attn")
            st.markdown('</div>', unsafe_allow_html=True)

            # 5. Recall
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown(
                f"**5. Delayed Recall** — Without prompting, ask the patient to recall "
                f"the 3 words from Step 3 ({words[0]}, {words[1]}, {words[2]})."
            )
            recall_count = st.radio("How many words did they recall correctly?",
                                     options=[0, 1, 2, 3], horizontal=True, key="recall")
            st.markdown('</div>', unsafe_allow_html=True)

            # 6. Language
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown("**6. Language** — Score each item the patient completes:")
            lang_naming = st.checkbox("Correctly named 2 everyday objects you showed them (2 pts)", key="lang1")
            lang_repeat = st.checkbox("Repeated 'No ifs, ands, or buts' correctly (1 pt)", key="lang2")
            lang_command = st.slider(
                "3-step command ('Take this paper, fold it in half, put it on the floor') — steps completed correctly",
                min_value=0, max_value=3, value=0, key="lang3"
            )
            st.markdown('</div>', unsafe_allow_html=True)

            # 7. Visuospatial
            st.markdown('<div class="section-card">', unsafe_allow_html=True)
            st.markdown("**7. Visuospatial / Reading & Writing**")
            vis_read = st.checkbox("Read and obeyed a written instruction (e.g. 'Close your eyes')", key="vis1")
            vis_write = st.checkbox("Wrote a complete, sensible sentence", key="vis2")
            vis_draw = st.checkbox("Copied two overlapping pentagons reasonably accurately", key="vis3")
            st.markdown('</div>', unsafe_allow_html=True)

            submitted = st.form_submit_button("Calculate Score →")

        if submitted:
            score = (
                sum([ot_year, ot_season, ot_month, ot_day, ot_date])
                + sum([op_country, op_state, op_city, op_building, op_floor])
                + reg_count
                + attn_count
                + recall_count
                + (2 if lang_naming else 0)
                + (1 if lang_repeat else 0)
                + lang_command
                + sum([vis_read, vis_write, vis_draw])
            )
            st.session_state.mmse_score = score

            label, desc = mt.interpret_score(score)
            st.success(f"✅ Test complete — Score: **{score} / 30**  →  {label}")
            st.caption(desc)

        st.write("")
        c1, c2 = st.columns(2)
        with c1:
            if st.button("← Back"):
                st.session_state.step = 1
                st.rerun()
        with c2:
            if st.session_state.mmse_score is not None:
                if st.button("Next: See Results  →"):
                    st.session_state.step = 3
                    st.rerun()
            else:
                st.button("Next: See Results  →", disabled=True,
                          help="Complete the test above first")


# ═══════════════════════════════════════════════════════════════════
# STEP 3 — Results
# ═══════════════════════════════════════════════════════════════════
elif st.session_state.step == 3:

    p = st.session_state.patient
    mmse = st.session_state.mmse_score
    gender_code = "M" if p["gender"] == "Male" else "F"

    with st.spinner("Running AI assessment…"):
        result = predictor.predict(
            age=p["age"], gender=gender_code,
            education=p["education"], ses=p["ses"], mmse=mmse,
        )

    prob = result["probability"]
    stage = result["stage"]
    emoji = result["emoji"]
    risk = result["risk_level"]

    colour_map = {
        "Normal":          ("#e8f5e9", "#2e7d32"),
        "Very Mild":       ("#fff9c4", "#f9a825"),
        "Mild":            ("#fff3e0", "#e65100"),
        "Moderate-Severe": ("#fce4ec", "#c62828"),
    }
    bg, fg = colour_map.get(stage, ("#f5f5f5", "#333"))

    st.markdown(f"""
    <div class="result-card" style="border-top: 5px solid {fg}; background:{bg}20;">
        <div class="stage-label" style="color:{fg};">{emoji} {stage}</div>
        <p style="color:#aaa; margin:4px 0 16px 0;">
            {'<b>No Dementia Detected</b>' if stage == 'Normal' else f'<b>Dementia Indicated — {stage} Stage</b>'}
        </p>
        <hr style="border-color:{fg}30;">
        <b>MMSE Score:</b> {mmse} / 30 &nbsp;&nbsp;
        <b>Risk Probability:</b> {prob}% &nbsp;&nbsp;
        <span style="background:{fg}; color:white; padding:3px 10px;
              border-radius:20px; font-size:13px;">{risk}</span>
    </div>
    """, unsafe_allow_html=True)

    st.markdown("**Risk Level**")
    st.progress(int(prob))

    if result["stage_cdr"] > 0:
        st.info(f"📋 Estimated CDR (Clinical Dementia Rating): **{result['stage_cdr']}**")

    st.markdown("### 💡 Recommendation")
    for line in result["recommendation"].split("\n"):
        st.markdown(line)

    st.markdown("---")
    st.caption(
        "⚠️ **Disclaimer:** This tool is for educational and screening purposes only. "
        "It is NOT a medical diagnosis. Always consult a qualified healthcare professional "
        "for clinical evaluation and treatment decisions."
    )

    st.write("")
    c1, c2 = st.columns(2)
    with c1:
        if st.button("← Redo Cognitive Test"):
            st.session_state.step = 2
            st.rerun()
    with c2:
        if st.button("🔄 Start New Assessment"):
            st.session_state.step = 1
            st.session_state.patient = {}
            st.session_state.mmse_score = None
            st.session_state.mmse_word_set = mt.pick_word_set()
            st.rerun()


# ── Sidebar: about ─────────────────────────────────────────────────
with st.sidebar:
    st.markdown("## About This Tool")
    st.markdown("""
This app uses a **stacking ensemble** (Random Forest + XGBoost) trained
on the **OASIS cross-sectional dataset** (436 patients), plus a second
XGBoost model to estimate dementia **stage**.

**Model performance (binary detection):**
- Accuracy: ~90%
- AUC: ~0.96

**What caregivers need:**
1. Patient's age & gender
2. Years of education
3. Rough socioeconomic status
4. A 10-minute guided cognitive test (built into this app — no
   external website required)

No MRI or lab values required!

---
**Dementia Stages (CDR):**
| CDR | Stage |
|-----|-------|
| 0   | Normal |
| 0.5 | Very Mild |
| 1   | Mild |
| 2+  | Moderate–Severe |

*(CDR 2 and 3 are grouped together because OASIS has very few
patients at these stages — keeping them separate made the model's
stage predictions unreliable.)*
    """)
