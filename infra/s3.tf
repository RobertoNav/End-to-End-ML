resource "aws_s3_bucket" "mlops_artifacts" {
  bucket = "mlops-housing-artifacts-${random_id.suffix.hex}"

  tags = {
    Name        = "MLOps Housing Artifacts"
    Project     = "mlops-housing"
    Environment = "dev"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
