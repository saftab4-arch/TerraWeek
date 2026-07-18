module "ec2" {
  source = "./modules/ec2"

  ami_id         = data.aws_ami.amazon_linux.id
  instance_type  = var.instance_type
  instance_count = var.instance_count
  instance_name  = "${var.project_name}-${var.environment}-ec2"
}
