output "ec2_public_ip" {
  description = "IP publica de la instancia EC2 requerida por la Persona 4"
  value       = aws_instance.mlops_server.public_ip
}

output "ec2_instance_id" {
  description = "ID de la instancia EC2 desplegada"
  value       = aws_instance.mlops_server.id
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 de la aplicacion"
  value       = aws_s3_bucket.app_bucket.id
}
