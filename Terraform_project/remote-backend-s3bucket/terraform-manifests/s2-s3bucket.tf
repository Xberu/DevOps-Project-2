resource "random_string" "suffix" {
  length  = 6
  special = false
  upper = false
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "tfstate-${var.environment_name}-${var.aws_region}-${random_string.suffix.result}"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name        = "tfstate-${var.environment_name}-${var.aws_region}"
    Environment = var.environment_name
    Project     = "remote-backend-for-devops-project"
    Purpose     = "Terraform state backend storage"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_bucket_versioning" {
  bucket = aws_s3_bucket.tfstate_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}