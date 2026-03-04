provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------------------------------
# INTENTIONALLY VULNERABLE: Public S3 bucket
# This bucket has public access enabled and contains
# a "secret" flag file. Your job: find and read it.
# -------------------------------------------------------

resource "aws_s3_bucket" "vulnerable" {
  bucket        = "ctf-challenge-01-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "CTF-Challenge-01"
    Environment = "ctf"
  }
}

# Block public access settings are DISABLED (vulnerability)
resource "aws_s3_bucket_public_access_block" "vulnerable" {
  bucket = aws_s3_bucket.vulnerable.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy allows public read (vulnerability)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.vulnerable.id
  depends_on = [aws_s3_bucket_public_access_block.vulnerable]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.vulnerable.arn}/*"
      }
    ]
  })
}

# Upload fake "sensitive" files
resource "aws_s3_object" "decoy_1" {
  bucket  = aws_s3_bucket.vulnerable.id
  key     = "public/readme.txt"
  content = "Welcome to the CTF. Nothing to see here."
}

resource "aws_s3_object" "decoy_2" {
  bucket  = aws_s3_bucket.vulnerable.id
  key     = "logs/access.log"
  content = "2024-01-01 GET /index.html 200\n2024-01-01 GET /about.html 200"
}

resource "aws_s3_object" "flag" {
  bucket  = aws_s3_bucket.vulnerable.id
  key     = "internal/config/app-secrets.json"
  content = jsonencode({
    db_password  = "sup3r$ecretP@ss"
    api_key      = "sk-prod-1234567890abcdef"
    flag         = "CTF{public_s3_data_exfil_success}"
    environment  = "production"
  })
}
