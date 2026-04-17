import os
import joblib
# Importamos boto3 para hablar con AWS
import boto3 
from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

# Nueva función para subir a S3
def upload_to_s3(file_name, bucket_name, object_name=None):
    """Sube un archivo a un bucket de S3"""
    if object_name is None:
        object_name = file_name

    # Inicializamos el cliente de S3
    s3_client = boto3.client('s3')
    
    try:
        print(f"Subiendo {file_name} al bucket '{bucket_name}' como '{object_name}'...")
        s3_client.upload_file(file_name, bucket_name, object_name)
        print("¡Subida completada con éxito!")
    except Exception as e:
        print(f"Error al subir a S3: {e}")

def train_and_save_model():
    # 1. Cargar el dataset de California Housing
    print("Cargando el dataset de California Housing...")
    data = fetch_california_housing()
    X = data.data    
    y = data.target  

    # 2. Dividir los datos 
    print("Dividiendo los datos en entrenamiento y prueba...")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 3. Entrenar el modelo
    print("Entrenando el modelo...")
    model = LinearRegression()
    model.fit(X_train, y_train)

    # 4. Evaluar el modelo 
    print("Evaluando el rendimiento...")
    predictions = model.predict(X_test)
    mse = mean_squared_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)
    print(f"MSE: {mse:.4f}")
    print(f"R2 Score: {r2:.4f}")

    # 5. Serializar (guardar) el modelo
    model_filename = "model.joblib"
    print(f"Empaquetando el modelo como '{model_filename}'...")
    joblib.dump(model, model_filename)
    print("¡Entrenamiento y serialización completados!")
    
    return model_filename # Devolvemos el nombre del archivo para usarlo en S3

if __name__ == "__main__":
    # Corremos el entrenamiento
    saved_model_file = train_and_save_model()
    
    # ---------------------------------------------------------
    # TODO: DESCOMENTAR ESTA SECCIÓN CUANDO TENGAMOS EL BUCKET
    # ---------------------------------------------------------
    
    # Aquí vamos a leer el nombre del bucket de las variables de entorno
    # que configurará Tirzah en el pipeline. Por ahora ponemos un nombre dummy
    BUCKET_NAME = "mlops-housing-artifacts-robertona"
    
    # La ruta exacta que acordaste con Saúl (ej. models/model.joblib)
    S3_PATH = f"models/{saved_model_file}"

    # Llamamos a la función de subida
    upload_to_s3(saved_model_file, BUCKET_NAME, S3_PATH)