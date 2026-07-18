output "ec2_instance_ids" {
  description = "IDs of the EC2 instances returned by the EC2 module"
  value       = module.ec2.instance_ids
}

output "ec2_private_ips" {
  description = "Private IP addresses returned by the EC2 module"
  value       = module.ec2.private_ips
}

output "ec2_instance_names" {
  description = "EC2 instance names returned by the EC2 module"
  value       = module.ec2.instance_names
}
