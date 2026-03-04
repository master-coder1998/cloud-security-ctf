output "lambda_url" {
  value = aws_lambda_function_url.public_url.function_url
}

output "flag_bucket_name" {
  value = aws_s3_bucket.flag_bucket.id
}
