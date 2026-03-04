provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------------------------------
# INTENTIONALLY VULNERABLE: Lambda function with
# 1. Unauthenticated public URL
# 2. Dangerous code execution via eval()
# 3. Overprivileged role (s3:* on all resources)
# Chain these to exfiltrate the flag from S3.
# -------------------------------------------------------

resource "aws_s3_bucket" "flag_bucket" {
  bucket        = "ctf-05-flag-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_object" "flag" {
  bucket  = aws_s3_bucket.flag_bucket.id
  key     = "flag.txt"
  content = "CTF{lambda_rce_to_s3_exfil}"
}

resource "aws_iam_role" "lambda_role" {
  name = "ctf-05-lambda-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# VULNERABILITY: overprivileged — s3:* on everything
resource "aws_iam_role_policy" "lambda_policy" {
  name = "ctf-05-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/ctf05_lambda.zip"
  source {
    # VULNERABILITY: eval() executes arbitrary user input
    content  = <<-JS
      const AWS = require('@aws-sdk/client-s3');

      exports.handler = async (event) => {
        const body = JSON.parse(event.body || '{}');
        
        // VULNERABILITY: eval on user-supplied input
        if (body.expression) {
          try {
            const result = eval(body.expression);
            return {
              statusCode: 200,
              body: JSON.stringify({ result: String(result) })
            };
          } catch(e) {
            return { statusCode: 500, body: JSON.stringify({ error: e.message }) };
          }
        }
        
        return {
          statusCode: 200,
          body: JSON.stringify({ message: "Send { expression: '...' } to evaluate" })
        };
      };
    JS
    filename = "index.js"
  }
}

resource "aws_lambda_function" "vulnerable" {
  function_name = "ctf-05-calculator-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      FLAG_BUCKET = aws_s3_bucket.flag_bucket.id
    }
  }
}

# VULNERABILITY: public Lambda URL with no auth
resource "aws_lambda_function_url" "public_url" {
  function_name      = aws_lambda_function.vulnerable.function_name
  authorization_type = "NONE"   # No authentication required
}
