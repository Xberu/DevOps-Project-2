# Resource Block: Random String
resource "random_string" "random" {
  length           = 6
  special          = false
  upper            = false
}

# Resource Block: AWS S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "devops-test-bucket-${random_string.random.result}"

  tags = {
    Name        = "my-test-bucket"
    Environment = "Dev"
  }
}