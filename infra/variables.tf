variable "aws_region" {
  description = "Región de AWS para desplegar los recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto para las etiquetas (tags) y nombres de recursos"
  type        = string
  default     = "mlops-housing"
}

variable "app_bucket_name" {
  description = "Nombre único del bucket S3 para los datos y el modelo (e.g. tu-equipo-mlops-housing-bucket)"
  type        = string
  default     = "mlops-housing-bucket"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}
