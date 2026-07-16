provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TerraWeek-Day-02"
      Environment = "Learning"
      ManagedBy   = "Terraform"
    }
  }
}
