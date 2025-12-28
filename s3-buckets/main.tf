provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket1" {
<<<<<<< HEAD
  bucket = "aluruarumullaa1-2025"

  tags = {
    Name        = "aluruarumullaa1-2025"
=======
  bucket = "cherGUI-r1heb-bucket1-2025-12-28"

  tags = {
    Name        = "cherGUI-r1heb-bucket1-2025-12-28"
>>>>>>> 734ec73 (Fix S3 bucket names to be unique)
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket1_versioning" {
  bucket = aws_s3_bucket.bucket1.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "arumullaaluruu1"

  tags = {
    Name        = "arumullaaluruu1"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket2_versioning" {
  bucket = aws_s3_bucket.bucket2.id
  versioning_configuration {
    status = "Enabled"
  }
}
