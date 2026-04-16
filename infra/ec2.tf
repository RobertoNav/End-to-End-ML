# Obtener la AMI de Ubuntu más reciente de forma dinámica
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Ubuntu Canonical Account ID
}

# Security group que permite el puerto 8000 (FastAPI), y SSH. También da salida full
resource "aws_security_group" "mlops_sg" {
  name        = "${var.project_name}-sg"
  description = "Trafico para app FastAPI e ingenieria"

  ingress {
    description = "FastAPI endpoint"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mlops_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.mlops_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.mlops_ec2_profile.name

  # Usar file function para cargar el script desde el archivo bootstrap.sh
  user_data = file("../scripts/bootstrap.sh")

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
