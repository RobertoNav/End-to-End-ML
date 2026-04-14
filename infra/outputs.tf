output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.mlops_ec2.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.mlops_artifacts.bucket
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.mlops_ec2.id
}
