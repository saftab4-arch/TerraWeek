variable "aws_region" {
  description = "AWS region where the EC2 instance will be created"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name used for resource tagging"
  type        = string
}
