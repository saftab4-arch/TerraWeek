variable "aws_region" {
  description = "AWS region where the Terraform backend resources will be created"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging AWS resources"
  type        = string
}

variable "environment" {
  description = "Environment name used for tagging AWS resources"
  type        = string
}
