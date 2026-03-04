output "instance_public_ip" {
  value = aws_instance.vulnerable.public_ip
}

output "flag_bucket_name" {
  value = aws_s3_bucket.flag_bucket.id
}

output "ssrf_app_url" {
  value = "http://${aws_instance.vulnerable.public_ip}:8080"
}
