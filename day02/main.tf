resource "aws_s3_bucket" "day2_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.bucket_name}-bucket"
  }
}
