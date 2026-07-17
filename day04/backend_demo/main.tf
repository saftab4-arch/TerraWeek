
resource "aws_instance" "backend_demo" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2"
  }
}
