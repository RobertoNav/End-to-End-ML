import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import List

import boto3
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


FEATURE_NAMES = [
	"MedInc",
	"HouseAge",
	"AveRooms",
	"AveBedrms",
	"Population",
	"AveOccup",
	"Latitude",
	"Longitude",
]


class PredictRequest(BaseModel):
	features: List[float]


model = None


def _download_model_from_s3(bucket_name: str, object_key: str, local_path: str) -> None:
	region = os.getenv("AWS_REGION")
	client = boto3.client("s3", region_name=region) if region else boto3.client("s3")
	client.download_file(bucket_name, object_key, local_path)


def load_model():
	local_model_path = os.getenv("MODEL_LOCAL_PATH", "model.joblib")
	s3_bucket = os.getenv("S3_BUCKET_NAME")
	s3_key = os.getenv("MODEL_S3_KEY", "models/model.joblib")

	if not Path(local_model_path).exists():
		if not s3_bucket:
			raise RuntimeError(
				"Model file not found locally and S3_BUCKET_NAME is not configured."
			)
		_download_model_from_s3(s3_bucket, s3_key, local_model_path)

	return joblib.load(local_model_path)



@asynccontextmanager
async def lifespan(_: FastAPI):
	global model
	model = load_model()
	yield


app = FastAPI(title="Housing Inference API", version="1.0.0", lifespan=lifespan)


@app.get("/health")
def health():
	return {"status": "ok", "model_loaded": model is not None}


@app.post("/predict")
def predict(payload: PredictRequest):
	if model is None:
		raise HTTPException(status_code=503, detail="Model is not loaded")

	if len(payload.features) != 8:
		raise HTTPException(
			status_code=422,
			detail=(
				"'features' must contain exactly 8 numeric values in this order: "
				+ ", ".join(FEATURE_NAMES)
			),
		)

	prediction = model.predict([payload.features])[0]
	return {
		"prediction": float(prediction),
		"feature_order": FEATURE_NAMES,
	}
