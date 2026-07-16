output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.day2_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.day2_bucket.arn
}

output "aws_region" {
  description = "AWS region used for this deployment"
  value       = var.aws_region
}
