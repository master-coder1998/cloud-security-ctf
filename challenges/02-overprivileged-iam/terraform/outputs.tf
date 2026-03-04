output "flag_bucket_name" {
  value = aws_s3_bucket.flag_bucket.id
}

output "vulnerable_role_arn" {
  value = aws_iam_role.vulnerable_ec2_role.arn
}

output "attacker_access_key_id" {
  value     = aws_iam_access_key.attacker_key.id
  sensitive = false
}

output "attacker_secret_key" {
  value     = aws_iam_access_key.attacker_key.secret
  sensitive = true
}
