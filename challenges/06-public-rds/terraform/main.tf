provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------------------------------
# INTENTIONALLY VULNERABLE: RDS instance that is
# publicly accessible with a weak security group
# and credentials stored in Terraform state.
# -------------------------------------------------------

resource "aws_vpc" "ctf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ctf_vpc.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.ctf_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.ctf_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
}

# VULNERABILITY: Security group allows MySQL from anywhere
resource "aws_security_group" "rds_sg" {
  name   = "ctf-06-rds-sg-${random_id.suffix.hex}"
  vpc_id = aws_vpc.ctf_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # VULNERABILITY: open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "ctf-06-subnet-group-${random_id.suffix.hex}"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# VULNERABILITY: publicly_accessible = true
resource "aws_db_instance" "vulnerable" {
  identifier        = "ctf-06-db-${random_id.suffix.hex}"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = var.db_password   # VULNERABILITY: also in tfstate

  publicly_accessible    = true   # VULNERABILITY
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  # Encryption disabled (vulnerability)
  storage_encrypted = false

  tags = {
    Name = "CTF-Challenge-06"
  }
}

# Seed data with the flag (run after RDS is up)
resource "null_resource" "seed_db" {
  depends_on = [aws_db_instance.vulnerable]

  provisioner "local-exec" {
    command = <<-EOF
      sleep 60  # wait for RDS to be ready
      mysql -h ${aws_db_instance.vulnerable.address} \
            -u admin \
            -p${var.db_password} \
            appdb << 'SQL'
      CREATE TABLE IF NOT EXISTS app_secrets (
        id INT PRIMARY KEY AUTO_INCREMENT,
        key_name VARCHAR(255),
        key_value VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      INSERT INTO app_secrets (key_name, key_value) VALUES
        ('stripe_key', 'sk_live_exposed_via_public_rds'),
        ('flag', 'CTF{public_rds_unencrypted_exposed}'),
        ('admin_password', 'NotSoSecretAdminPass123');
      SQL
    EOF
  }
}
