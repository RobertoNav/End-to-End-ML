# Política de asunción de rol para que la EC2 pueda asumir este rol
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mlops_ec2_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Política en línea para permitir lectura/escritura SOLO sobre el bucket s3 de la aplicación
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.app_bucket.arn,
      "${aws_s3_bucket.app_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_access_attachment" {
  name   = "${var.project_name}-s3-access"
  role   = aws_iam_role.mlops_ec2_role.id
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

# Adjuntar la política administrada por AWS para que SSM (Session Manager) funcione
resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.mlops_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Perfil de instancia para adherirlo a la EC2
resource "aws_iam_instance_profile" "mlops_ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.mlops_ec2_role.name
}
