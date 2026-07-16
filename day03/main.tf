resource "aws_s3_bucket" "day3_bucket" {

  bucket = var.bucket_name

  tags = local.common_tags

}
