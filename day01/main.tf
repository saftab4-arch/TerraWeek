resource "aws_s3_bucket" "day1_bucket" {
  bucket = "syed-terraweek-day1-2026"

  tags = {
    Name = "TerraWeek-Day-01-Bucket"
  }
}
