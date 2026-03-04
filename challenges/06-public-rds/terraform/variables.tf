variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  default     = "Ctf_Passw0rd_2024!"
  sensitive   = true
}
