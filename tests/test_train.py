import pytest
from sklearn.datasets import fetch_california_housing
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score


def test_data_loading():
    """Test that California Housing dataset loads correctly."""
    data = fetch_california_housing()
    X = data.data
    y = data.target

    assert X.shape[0] == y.shape[0]
    assert X.shape[1] == 8  # 8 features


def test_model_training():
    """Test that the model trains and produces valid predictions."""
    data = fetch_california_housing()
    X = data.data
    y = data.target

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = LinearRegression()
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)

    # Model should produce predictions with correct shape
    assert predictions.shape[0] == X_test.shape[0]

    # R2 should be positive (model performs better than predicting mean)
    r2 = r2_score(y_test, predictions)
    assert r2 > 0.4  # California Housing typically gets ~0.6


def test_model_serialization():
    """Test that model can be serialized and deserialized."""
    import joblib
    import tempfile
    import os

    data = fetch_california_housing()
    X = data.data
    y = data.target

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = LinearRegression()
    model.fit(X_train, y_train)

    # Serialize
    with tempfile.NamedTemporaryFile(suffix=".joblib", delete=False) as f:
        joblib.dump(model, f.name)
        model_path = f.name

    try:
        # Deserialize
        loaded_model = joblib.load(model_path)
        predictions = loaded_model.predict(X_test)

        assert predictions.shape[0] == X_test.shape[0]
    finally:
        os.remove(model_path)
