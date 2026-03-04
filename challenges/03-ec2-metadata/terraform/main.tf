provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------------------------------
# INTENTIONALLY VULNERABLE: IMDSv1 enabled (no token required)
# The EC2 instance uses IMDSv1, allowing any process on
# the instance (including SSRF targets) to query metadata
# and steal IAM credentials without authentication.
# -------------------------------------------------------

resource "aws_iam_role" "ec2_role" {
  name = "ctf-03-ec2-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ctf-03-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.flag_bucket.arn,
          "${aws_s3_bucket.flag_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "profile" {
  name = "ctf-03-profile-${random_id.suffix.hex}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_s3_bucket" "flag_bucket" {
  bucket        = "ctf-03-flag-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_object" "flag" {
  bucket  = aws_s3_bucket.flag_bucket.id
  key     = "flag.txt"
  content = "CTF{imdsv1_ssrf_credential_theft}"
}

resource "aws_security_group" "ec2_sg" {
  name = "ctf-03-sg-${random_id.suffix.hex}"

  # Allow SSH for challenge access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP in real use
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VULNERABILITY: http_tokens = "optional" enables IMDSv1
resource "aws_instance" "vulnerable" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"   # VULNERABILITY: should be "required"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum install -y python3
    # Simulated web app vulnerable to SSRF
    cat > /home/ec2-user/app.py << 'PYEOF'
import http.server
import urllib.request

class SSRFHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # VULNERABILITY: fetches any URL provided by user (SSRF)
        url = self.path.lstrip('/')
        if not url:
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Usage: /?url=http://example.com")
            return
        try:
            import urllib.parse
            decoded_url = urllib.parse.unquote(url[4:]) if url.startswith('url=') else url
            with urllib.request.urlopen(decoded_url, timeout=3) as resp:
                data = resp.read()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode())

    def log_message(self, format, *args):
        pass

server = http.server.HTTPServer(('0.0.0.0', 8080), SSRFHandler)
server.serve_forever()
PYEOF
    python3 /home/ec2-user/app.py &
  EOF

  tags = {
    Name = "CTF-Challenge-03-Vulnerable"
  }
}
