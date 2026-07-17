terraform {
  backend "s3" {
    bucket       = "saftab4-terraweek-day04-state"
    key          = "backend-demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
