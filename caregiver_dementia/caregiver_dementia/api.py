from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import sys
from pathlib import Path
from fastapi.middleware.cors import CORSMiddleware

# Allow importing src/
BASE_DIR = Path(__file__).resolve().parent
sys.path.append(str(BASE_DIR / "src"))

from predict import CaregiverPredictor

app = FastAPI(
    title="Dementia Prediction API",
    version="1.0"
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # or ["http://localhost:59032"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

predictor = CaregiverPredictor()


class DementiaRequest(BaseModel):
    gender: int
    age: float
    educ: float
    ses: float
    mmse: float


@app.get("/")
def home():
    return {
        "message": "Dementia Prediction API Running"
    }


@app.post("/api/dementia/predict")
def predict(req: DementiaRequest):

    gender = "M" if req.gender == 1 else "F"

    result = predictor.predict(
        age=req.age,
        gender=gender,
        education=req.educ,
        ses=req.ses,
        mmse=req.mmse,
    )

    return {
        "prediction": 1 if result["has_dementia"] else 0,
        "probability": result["probability"] / 100,
        "label": result["stage"],
        "riskLevel": result["risk_level"],
        "recommendation": result["recommendation"],
        "stage": result["stage"],
        "stage_cdr": result["stage_cdr"],
        "emoji": result["emoji"]
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)