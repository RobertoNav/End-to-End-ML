import sys
from pathlib import Path
import joblib

# Agregar src al path
sys.path.append(str(Path(__file__).resolve().parents[1] / "src"))

from train import train_and_save_model  # noqa: E402


def test_train_and_save_model_creates_joblib_file(tmp_path, monkeypatch):
    """
    Verifica que:
    - el entrenamiento corre sin errores
    - se genera model.joblib
    - el modelo es válido
    """
    monkeypatch.chdir(tmp_path)

    model_filename = train_and_save_model()
    model_path = tmp_path / model_filename

    assert model_filename == "model.joblib"
    assert model_path.exists()

    loaded_model = joblib.load(model_path)
    assert hasattr(loaded_model, "predict")


def test_train_and_save_model_returns_filename(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)

    model_filename = train_and_save_model()

    assert model_filename == "model.joblib"
