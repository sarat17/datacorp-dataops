provider "aws" {
  region = "us-east-1"
}

variable "db_password" {
  type      = string
  sensitive = true
}

# 1. Bucket S3 para datos de staging
resource "aws_s3_bucket" "staging_data" {
  bucket = "datacorp-staging-data"
  tags = {
    Environment = "staging"
  }
}

# 2. Instancia EC2 para DEV
resource "aws_instance" "dev_server" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.small"
  tags = {
    Environment = "dev"
  }
}

# 3. Base de datos RDS para PROD
resource "aws_db_instance" "prod_db" {
  identifier        = "datacorp-prod-db"
  engine            = "postgres"
  instance_class    = "db.m5.large"
  allocated_storage = 100
  multi_az          = true
  storage_encrypted = true
  username          = "admin_datacorp"
  password          = var.db_password
}

# 4. Rol IAM con permisos restringidos
resource "aws_iam_role" "pipeline_role" {
  name = "datacorp-pipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "acceso_minimo_staging" {
  name = "acceso-minimo-staging"
  role = aws_iam_role.pipeline_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:PutObject"]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::datacorp-staging-data/*"
    }]
  })
}
