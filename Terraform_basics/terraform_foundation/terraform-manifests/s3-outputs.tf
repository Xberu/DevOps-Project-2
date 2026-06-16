# output blocks

output "s3_bucket_name" {
    value = awws_s3_bucket.test_bucket.bucket
}
output "s3_bucket_id" {
    value = awws_s3_bucket.test_bucket.id
}
output "s3_bucket_arn" {
    value = awws_s3_bucket.test_bucket.arn
    description = "s3bucket ARN"
}