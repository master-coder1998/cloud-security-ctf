output "function_name" {
  value = aws_lambda_function.vulnerable.function_name
}

output "attacker_access_key_id" {
  value = aws_iam_access_key.attacker_key.id
}

output "attacker_secret_key" {
  value     = aws_iam_access_key.attacker_key.secret
  sensitive = true
}
