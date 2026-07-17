output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.backend_demo.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.backend_demo.private_ip
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI selected by the data source"
  value       = data.aws_ami.amazon_linux.id
}

output "remote_state_location" {
  description = "S3 location of the Terraform state file"
  value       = "s3://saftab4-terraweek-day04-state/backend-demo/terraform.tfstate"
}
