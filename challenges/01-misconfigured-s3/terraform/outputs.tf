output "bucket_name" {
  value       = aws_s3_bucket.vulnerable.id
  description = "The name of the vulnerable S3 bucket"
}

output "bucket_url" {
  value       = "https://${aws_s3_bucket.vulnerable.id}.s3.amazonaws.com"
  description = "Public URL of the bucket"
}
