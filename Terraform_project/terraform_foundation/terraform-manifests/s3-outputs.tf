# output blocks

output "s3_bucket_name" {
    value = aws_s3_bucket.test_bucket.bucket
}
output "s3_bucket_id" {
    value = aws_s3_bucket.test_bucket.id
}
output "s3_bucket_arn" {
    value = aws_s3_bucket.test_bucket.arn
    description = "s3bucket ARN"
}