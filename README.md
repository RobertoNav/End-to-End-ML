# End-to-End ML — California Housing

Pipeline MLOps de punta a punta: entrenamiento de un modelo de regresión sobre el dataset *California Housing*, publicación del artefacto en S3, despliegue de una API de inferencia FastAPI en EC2 mediante Terraform, y validación automatizada vía GitHub Actions.

## Arquitectura

```
GitHub Actions ──► Terraform ──► EC2 (Ubuntu)
      │                             │
      │                             └─► bootstrap.sh
      │                                   ├─ pip install -r requirements.txt
      │                                   ├─ python src/train.py ──► S3 (modelo)
      │                                   └─ uvicorn src.app:app  ◄── S3 (modelo)
      │
      └─► Smoke tests contra /health y /predict
```

## Estructura del repo

```
.
├── .github/workflows/deploy.yml   # CI/CD: lint, tests, terraform apply, smoke tests
├── infra/                         # Terraform (EC2, S3, IAM, variables, outputs)
├── scripts/bootstrap.sh           # User-data: entrena, sube a S3 y levanta la API
├── src/
│   ├── train.py                   # Entrena LinearRegression y sube model.joblib a S3
│   └── app.py                     # FastAPI con /health y /predict
├── tests/
│   ├── test_train.py              # Tests unitarios del pipeline de entrenamiento
│   └── test_endpoints.py          # Tests de integración de la API
└── requirements.txt
```

## Modelo

- **Dataset:** `sklearn.datasets.fetch_california_housing`
- **Algoritmo:** `LinearRegression`
- **Split:** 80/20 (`random_state=42`)
- **Métricas:** MSE y R² sobre el set de prueba
- **Artefacto:** `model.joblib` publicado en `s3://mlops-housing-artifacts-robertona/models/model.joblib`

### Features (orden requerido por `/predict`)
`MedInc`, `HouseAge`, `AveRooms`, `AveBedrms`, `Population`, `AveOccup`, `Latitude`, `Longitude`

## API

Servida con Uvicorn en el puerto `8000`.

| Método | Ruta       | Descripción                                        |
|--------|------------|----------------------------------------------------|
| GET    | `/health`  | Estado del servicio y si el modelo está cargado.   |
| POST   | `/predict` | Predice el valor medio de la vivienda.             |

Ejemplo:

```bash
curl -X POST http://<ENDPOINT_IP>:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [8.3, 41.0, 6.98, 1.02, 322.0, 2.56, 37.88, -122.23]}'
```

### Variables de entorno relevantes
- `S3_BUCKET_NAME` — bucket donde vive el modelo.
- `MODEL_S3_KEY` — key del objeto (default `models/model.joblib`).
- `MODEL_LOCAL_PATH` — ruta local de carga (default `model.joblib`).
- `AWS_REGION` — región para el cliente de S3.

## Infraestructura (Terraform)

Archivos en `infra/`:
- `main.tf` — provider AWS y backend remoto en S3 + lock en DynamoDB.
- `ec2.tf` — instancia EC2 que corre `bootstrap.sh`.
- `s3.tf` — bucket de artefactos del modelo.
- `iam.tf` — rol y policy para que la EC2 lea/escriba en S3.
- `variables.tf` / `outputs.tf` — parámetros y outputs (`ec2_public_ip`, `ec2_instance_id`).

### Backend
- Estado: `s3://mlops-estado-terraform-robertona/mlops/terraform.tfstate`
- Lock: DynamoDB `mlops-terraform-locks`

## CI/CD (`.github/workflows/deploy.yml`)

Triggers: `push` a `main`. Tres jobs encadenados:

1. **ci** — instala dependencias, corre `flake8` y `pytest tests/test_train.py`.
2. **deploy** — `terraform apply -replace=aws_instance.mlops_server` para forzar reemplazo y re-ejecución del bootstrap; expone `endpoint_ip` e `instance_id`.
3. **validate** — espera a que la EC2 pase status checks, hace polling a `/health` (hasta 15 min) y ejecuta smoke tests contra `/health` y `/predict`.

Secrets necesarios: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.

## Uso local

```bash
pip install -r requirements.txt

# Entrenar (sube a S3 si las credenciales AWS están configuradas)
python src/train.py

# Servir la API
uvicorn src.app:app --host 0.0.0.0 --port 8000

# Tests
pytest tests/ -v
```

## Requisitos

- Python 3.10+
- Terraform ≥ 1.0
- Credenciales AWS con permisos sobre S3, EC2, IAM y DynamoDB
