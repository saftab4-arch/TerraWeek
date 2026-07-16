output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.day3_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.day3_bucket.arn
}

output "environment" {
  description = "Environment used for this deployment"
  value       = var.environment
}

output "common_tags" {
  description = "Common tags applied to the S3 bucket"
  value       = local.common_tags
}
