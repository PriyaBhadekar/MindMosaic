"""
mmse_test.py
────────────
A self-contained, in-app cognitive screening test inspired by the
Mini-Mental State Examination (MMSE). This lets a caregiver administer
the test directly inside the app instead of relying on a broken external
link or a separate platform.

NOTE: This is a *simplified screening adaptation*, not the licensed
official MMSE instrument (the real MMSE is copyrighted by PAR Inc.).
It mirrors the same cognitive domains and a comparable 0–30 scoring
range so it plugs directly into the existing prediction pipeline.

Domains covered (same structure as the standard MMSE):
  1. Orientation to time        (5 pts)
  2. Orientation to place        (5 pts)
  3. Registration (3-word recall, immediate)   (3 pts)
  4. Attention & calculation     (5 pts)
  5. Recall (the same 3 words, delayed)        (3 pts)
  6. Language & naming           (6 pts)
  7. Visuospatial / following instructions     (3 pts)
                                  ─────────
                                  Total: 30 pts
"""

import datetime
import random

# Word list for the registration/recall task — rotated each session
WORD_SETS = [
    ["Apple", "Table", "Penny"],
    ["Ball", "Flag", "Tree"],
    ["Shirt", "Brown", "Honesty"],
]


def get_today_questions():
    """Returns orientation questions with today's correct answers."""
    today = datetime.date.today()
    return {
        "year": today.year,
        "season": _season(today.month),
        "month": today.strftime("%B"),
        "day_of_week": today.strftime("%A"),
        "date": today.day,
    }


def _season(month):
    if month in (12, 1, 2):
        return "Winter"
    if month in (3, 4, 5):
        return "Spring"
    if month in (6, 7, 8):
        return "Summer"
    return "Autumn"


def pick_word_set():
    return random.choice(WORD_SETS)


TEST_STRUCTURE = {
    "orientation_time": {
        "title": "1. Orientation to Time",
        "max_score": 5,
        "instructions": "Ask the patient the following. 1 point each for a correct answer.",
        "items": ["Year", "Season", "Month", "Day of the week", "Date (day of month)"],
    },
    "orientation_place": {
        "title": "2. Orientation to Place",
        "max_score": 5,
        "instructions": "Ask the patient to name the following. 1 point each.",
        "items": ["Country", "State/Province", "City/Town", "Building/Place they are in", "Floor or room"],
    },
    "registration": {
        "title": "3. Registration (Immediate Recall)",
        "max_score": 3,
        "instructions": (
            "Say 3 unrelated words clearly, one second apart. Ask the patient to repeat "
            "them back immediately. 1 point per word repeated correctly (first attempt)."
        ),
    },
    "attention": {
        "title": "4. Attention & Calculation",
        "max_score": 5,
        "instructions": (
            "Ask the patient to count backward from 100 by 7s, five times "
            "(100, 93, 86, 79, 72). 1 point per correct subtraction. "
            "If they cannot do this, ask them to spell 'WORLD' backwards instead "
            "and score 1 point per correctly placed letter."
        ),
    },
    "recall": {
        "title": "5. Delayed Recall",
        "max_score": 3,
        "instructions": (
            "Ask the patient to recall the same 3 words from step 3 "
            "(without prompting). 1 point per word recalled correctly."
        ),
    },
    "language": {
        "title": "6. Language",
        "max_score": 6,
        "instructions": "Score 1 point for each of the following the patient completes correctly.",
        "items": [
            "Name two everyday objects you show them (e.g. pen, watch) — 2 pts",
            "Repeat the phrase 'No ifs, ands, or buts' — 1 pt",
            "Follow a 3-step command (e.g. 'Take this paper, fold it in half, put it on the floor') — 3 pts",
        ],
    },
    "visuospatial": {
        "title": "7. Visuospatial / Reading & Writing",
        "max_score": 3,
        "instructions": "Score 1 point for each completed correctly.",
        "items": [
            "Read and obey a written instruction (e.g. 'Close your eyes') — 1 pt",
            "Write a complete sentence — 1 pt",
            "Copy a simple drawing of two overlapping pentagons — 1 pt",
        ],
    },
}


def total_max_score():
    return sum(section["max_score"] for section in TEST_STRUCTURE.values())  # = 30


def interpret_score(score):
    """Returns (label, description) for a given MMSE-style score."""
    if score >= 27:
        return "Normal", "No significant cognitive impairment indicated."
    elif score >= 21:
        return "Mild Impairment", "Some cognitive difficulty — further evaluation recommended."
    elif score >= 11:
        return "Moderate Impairment", "Noticeable cognitive difficulty — clinical evaluation advised."
    else:
        return "Severe Impairment", "Significant cognitive difficulty — prompt clinical evaluation advised."
