terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   # IMPORTANTE: Cambiar valores cuando se cree el bucket y tabla o crear mediante un pre-script.
  #   # Por mientras está comentado para permitir a Github Actions realizar su primera prueba satisfactoriamente.
  #   bucket         = "TU_BUCKET_DE_ESTADO_TERRAFORM"
  #   key            = "mlops/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "TU_TABLA_DYNAMODB_TERRAFORM"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
