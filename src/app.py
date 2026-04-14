import os
import joblib
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI()

class Features(BaseModel):
    features: List[float]

# Load model on startup (dummy path for local testing)
model_path = "model.joblib"
model = None

@app.on_event("startup")
def load_model():
    global model
    if os.path.exists(model_path):
        model = joblib.load(model_path)
        print("Model loaded successfully.")
    else:
        print("Model not found. Will load after training completes.")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(features: Features):
    if model is None:
        return {"error": "Model not loaded"}
    prediction = model.predict([features.features]).tolist()
    return {"prediction": prediction}
