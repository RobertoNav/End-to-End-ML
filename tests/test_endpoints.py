import sys
from pathlib import Path
import importlib

import joblib
from fastapi.testclient import TestClient
from sklearn.linear_model import LinearRegression

# Agregar src al path
sys.path.append(str(Path(__file__).resolve().parents[1] / "src"))


def _build_test_client(tmp_path, monkeypatch):
    X = [
        [8.3, 41.0, 6.98, 1.02, 322.0, 2.56, 37.88, -122.23],
        [7.0, 35.0, 5.5, 1.1, 280.0, 2.0, 34.0, -118.0],
    ]
    y = [4.5, 3.2]
    model = LinearRegression().fit(X, y)

    model_path = tmp_path / "model.joblib"
    joblib.dump(model, model_path)

    monkeypatch.setenv("MODEL_LOCAL_PATH", str(model_path))
    monkeypatch.delenv("S3_BUCKET_NAME", raising=False)

    if "app" in sys.modules:
        del sys.modules["app"]

    app_module = importlib.import_module("app")
    return TestClient(app_module.app)


def test_health_endpoint(tmp_path, monkeypatch):
    client = _build_test_client(tmp_path, monkeypatch)

    with client as active_client:
        response = active_client.get("/health")
        assert response.status_code == 200

        data = response.json()
        assert data["status"] == "ok"
        assert data["model_loaded"] is True


def test_predict_endpoint(tmp_path, monkeypatch):
    client = _build_test_client(tmp_path, monkeypatch)

    payload = {
        "features": [8.3, 41.0, 6.98, 1.02, 322.0, 2.56, 37.88, -122.23]
    }

    with client as active_client:
        response = active_client.post("/predict", json=payload)
        assert response.status_code == 200

        data = response.json()
        assert "prediction" in data
        assert isinstance(data["prediction"], float)
        assert "feature_order" in data
        assert isinstance(data["feature_order"], list)
        assert len(data["feature_order"]) == 8


def test_predict_endpoint_rejects_invalid_feature_length(tmp_path, monkeypatch):
    client = _build_test_client(tmp_path, monkeypatch)

    payload = {"features": [8.3, 41.0]}

    with client as active_client:
        response = active_client.post("/predict", json=payload)
        assert response.status_code == 422
