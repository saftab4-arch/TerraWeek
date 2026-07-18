provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TerraWeek-Day-06"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
