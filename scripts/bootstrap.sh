#!/bin/bash
set -e

# Bootstrap script for EC2 instance
echo "Starting EC2 bootstrap..."

# Update and install dependencies
apt-get update -y
apt-get install -y python3-pip python3-venv

# Create virtual environment
python3 -m venv /home/ubuntu/mlops-env
source /home/ubuntu/mlops-env/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r /home/ubuntu/End-to-End-ML/requirements.txt

# Set environment variables
export S3_BUCKET_NAME=$(aws s3 ls --query 'Buckets[].Name' --output text | grep mlops-housing)
export MODEL_PATH="s3://${S3_BUCKET_NAME}/models/model.joblib"

# Run training
cd /home/ubuntu/End-to-End-ML
python3 src/train.py

# Upload model to S3
aws s3 cp model.joblib s3://${S3_BUCKET_NAME}/models/model.joblib

# Start FastAPI server
cd /home/ubuntu/End-to-End-ML/src
nohup uvicorn app:app --host 0.0.0.0 --port 8000 &

echo "Bootstrap complete. Inference API running on port 8000."
