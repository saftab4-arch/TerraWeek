variable "ami_id" {
  description = "AMI ID used to launch the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 3
    error_message = "Instance count must be between 1 and 3."
  }
}

variable "instance_name" {
  description = "Base name used for the EC2 instances"
  type        = string
}
