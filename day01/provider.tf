provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "Terraform-Day-01"
      Environment = "Learning"
      ManagedBy   = "Terraform"
    }
  }
}
