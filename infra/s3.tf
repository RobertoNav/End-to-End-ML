resource "aws_s3_bucket" "app_bucket" {
  bucket        = var.app_bucket_name
  force_destroy = true # IMPORTANTE: Para permitir el terraform destroy sin problemas en un lab
}

# La propiedad de ACL ya no se usa mucho por seguridad. Usaremos Object Ownership
resource "aws_s3_bucket_ownership_controls" "app_bucket_ownership" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Bloquear acceso público total al bucket (seguridad por defecto)
resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
