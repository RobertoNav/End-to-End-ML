#!/bin/bash
# (Axel pondrá aquí sus comandos de sudo apt-get update, etc.)

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

# (Aquí Saúl pondrá el comando para levantar FastAPI: uvicorn src.app:app ...)