variable "aws_region" {
  description = "AWS region where the backend infrastructure will be created"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform remote state S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name used for resource tagging"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}
