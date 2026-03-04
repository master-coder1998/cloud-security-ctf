provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------------------------------
# INTENTIONALLY VULNERABLE: Overprivileged IAM role
# An EC2 instance has an IAM role with far too many
# permissions. Use it to escalate privileges and
# access resources you shouldn't be able to reach.
# -------------------------------------------------------

# S3 bucket with the flag (should be restricted)
resource "aws_s3_bucket" "flag_bucket" {
  bucket        = "ctf-02-flag-bucket-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_object" "flag" {
  bucket  = aws_s3_bucket.flag_bucket.id
  key     = "secret/flag.txt"
  content = "CTF{iam_privilege_escalation_via_overprivileged_role}"
}

# Overprivileged IAM policy (vulnerability: wildcard actions)
resource "aws_iam_policy" "overprivileged" {
  name = "ctf-02-overprivileged-policy-${random_id.suffix.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Intended: read-only EC2 describe permissions
        Sid    = "EC2ReadOnly"
        Effect = "Allow"
        Action = "ec2:Describe*"
        Resource = "*"
      },
      {
        # VULNERABILITY: wildcard on IAM — allows privilege escalation
        Sid    = "IAMWildcard"
        Effect = "Allow"
        Action = "iam:*"
        Resource = "*"
      },
      {
        # VULNERABILITY: wildcard on S3 — unintended data access
        Sid    = "S3Wildcard"
        Effect = "Allow"
        Action = "s3:*"
        Resource = "*"
      }
    ]
  })
}

# IAM role for EC2
resource "aws_iam_role" "vulnerable_ec2_role" {
  name = "ctf-02-ec2-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.vulnerable_ec2_role.name
  policy_arn = aws_iam_policy.overprivileged.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "ctf-02-instance-profile-${random_id.suffix.hex}"
  role = aws_iam_role.vulnerable_ec2_role.name
}

# Simulated "attacker" IAM user with limited initial permissions
resource "aws_iam_user" "attacker" {
  name = "ctf-02-attacker-${random_id.suffix.hex}"
}

resource "aws_iam_user_policy" "attacker_policy" {
  name = "ctf-02-attacker-base-policy"
  user = aws_iam_user.attacker.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Attacker can list and assume roles (but shouldn't get admin)
        Effect   = "Allow"
        Action   = ["iam:ListRoles", "sts:AssumeRole"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "attacker_key" {
  user = aws_iam_user.attacker.name
}
