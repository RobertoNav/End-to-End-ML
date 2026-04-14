output "ec2_public_ip" {
  description = "IP pública de la instancia EC2 requerida por la Persona 4"
  value       = aws_instance.mlops_server.public_ip
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 de la aplicación"
  value       = aws_s3_bucket.app_bucket.id
}
