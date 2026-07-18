output "instance_ids" {
  description = "IDs of the EC2 instances created by the module"
  value       = aws_instance.this[*].id
}

output "private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.this[*].private_ip
}

output "instance_names" {
  description = "Name tags assigned to the EC2 instances"
  value       = aws_instance.this[*].tags["Name"]
}
