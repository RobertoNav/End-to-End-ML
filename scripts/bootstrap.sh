#!/bin/bash
set -euxo pipefail

# Actualizar el sistema e instalar Python, pip y dependencias básicas
sudo apt-get update -y
sudo apt-get install -y python3-pip python3-venv git awscli

# ==============================================================================
# BLOQUE DE INFRAESTRUCTURA (PERSONA 3)
# Clonar el repositorio para tener acceso al código y los requerimientos.
# ==============================================================================
cd /home/ubuntu

if [ -d End-to-End-ML/.git ]; then
	cd End-to-End-ML
	git fetch origin
	git checkout main
	git pull origin main
else
	git clone https://github.com/RobertoNav/End-to-End-ML.git
	cd End-to-End-ML
fi

# Obtener el código más reciente de main
echo "Pulling latest code from main branch..."
git pull origin main
echo "Repository updated. Current commit:"
git log -1 --oneline
echo "Bootstrap version: $(date)"

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

# Espera activa para confirmar que la app está lista antes de terminar bootstrap
for i in {1..30}; do
	if curl -s http://127.0.0.1:8000/health | grep -q '"status":"ok"'; then
		echo "FastAPI healthy after $((i * 5)) seconds"
		break
	fi

	if [ "$i" -eq 30 ]; then
		echo "FastAPI did not become healthy in time"
		tail -n 100 /var/log/mlops-api.log || true
		exit 1
	fi

	sleep 5
done

echo "Bootstrap completado exitosamente en: $(date)"