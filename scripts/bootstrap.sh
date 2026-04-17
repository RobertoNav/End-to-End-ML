#!/bin/bash
# Actualizar el sistema e instalar Python, pip y dependencias básicas
sudo apt-get update -y
sudo apt-get install -y python3-pip python3-venv git awscli

# ==============================================================================
# BLOQUE DE INFRAESTRUCTURA (PERSONA 3)
# Clonar el repositorio para tener acceso al código y los requerimientos.
# ==============================================================================
cd /home/ubuntu
git clone https://github.com/RobertoNav/End-to-End-ML.git
cd End-to-End-ML

# Dar permisos al usuario ubuntu
chown -R ubuntu:ubuntu /home/ubuntu/End-to-End-ML

# ==============================================================================
# BLOQUE DE JOSÉ JUAN (TRAINING PIPELINE)
# Este bloque instala las librerías, entrena el modelo y lo sube a S3.
# ==============================================================================
echo "Iniciando Pipeline de Entrenamiento..."

# 1. Instalar librerías
pip3 install -r requirements.txt

# 2. Ejecutar el script que entrena y sube el modelo
# Asegurarse de estar en la carpeta raíz del proyecto antes de correr esto
python3 src/train.py

echo "Entrenamiento finalizado. Modelo listo en S3."
# ==============================================================================

echo "Iniciando servidor FastAPI..."

# Variables de entorno para que app.py ubique el artefacto en S3
export S3_BUCKET_NAME="mlops-housing-artifacts-robertona"
export MODEL_S3_KEY="models/model.joblib"

# Levantar API en segundo plano en puerto 8000
nohup python3 -m uvicorn src.app:app --host 0.0.0.0 --port 8000 > /var/log/mlops-api.log 2>&1 &

echo "FastAPI iniciada en puerto 8000. Log: /var/log/mlops-api.log"