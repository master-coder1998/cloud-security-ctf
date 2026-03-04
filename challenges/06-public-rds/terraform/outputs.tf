output "rds_endpoint" {
  value = aws_db_instance.vulnerable.address
}

output "rds_port" {
  value = aws_db_instance.vulnerable.port
}

output "db_username" {
  value = "admin"
}

output "db_name" {
  value = "appdb"
}
