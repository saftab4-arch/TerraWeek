terraform {
  backend "s3" {
    bucket       = "saftab4-terraweek-day05-state"
    key          = "modules-demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
