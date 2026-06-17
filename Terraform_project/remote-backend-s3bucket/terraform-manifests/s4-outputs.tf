output "aws_region" {
  value = var.aws_region 
}

output "environment_name" {
  value = var.environment_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.tfstate_bucket.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.tfstate_bucket.arn
}
output "s3_bucket_id" {
  value = aws_s3_bucket.tfstate_bucket.id
}

