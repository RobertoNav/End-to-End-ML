terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Remote backend for shared state (S3 + DynamoDB)
  # Uncomment and configure for team usage:
  # backend "s3" {
  #   bucket         = "mlops-housing-terraform-state"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "mlops-housing-terraform-lock"
  # }
}

provider "aws" {
  region = var.aws_region
}
