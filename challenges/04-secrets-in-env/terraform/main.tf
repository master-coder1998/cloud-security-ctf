provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 4
}

# -------------------------------------------------------
# INTENTIONALLY VULNERABLE: Secrets stored as plaintext
# environment variables in a Lambda function.
# Anyone with lambda:GetFunctionConfiguration can read them.
# -------------------------------------------------------

resource "aws_iam_role" "lambda_role" {
  name = "ctf-04-lambda-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function with secrets in plaintext env vars (vulnerability)
resource "aws_lambda_function" "vulnerable" {
  function_name = "ctf-04-app-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = data.archive_file.lambda_zip.output_path

  # VULNERABILITY: secrets stored as plaintext environment variables
  environment {
    variables = {
      DB_HOST         = "prod-db.internal.example.com"
      DB_USERNAME     = "admin"
      DB_PASSWORD     = "Pr0d$ecretDBpass!"       # should be in Secrets Manager
      STRIPE_API_KEY  = "sk_live_abcdef1234567890"  # should be in Secrets Manager
      JWT_SECRET      = "my-super-secret-jwt-key"   # should be in Secrets Manager
      FLAG            = "CTF{plaintext_secrets_in_lambda_env}"
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/lambda.zip"
  source {
    content  = <<-JS
      exports.handler = async (event) => {
        return {
          statusCode: 200,
          body: JSON.stringify({ message: "Hello from CTF Lambda" })
        };
      };
    JS
    filename = "index.js"
  }
}

# Attacker user — has lambda:GetFunctionConfiguration
resource "aws_iam_user" "attacker" {
  name = "ctf-04-attacker-${random_id.suffix.hex}"
}

resource "aws_iam_user_policy" "attacker_policy" {
  name = "ctf-04-attacker-policy"
  user = aws_iam_user.attacker.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:GetFunctionConfiguration"   # This is all that's needed
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "attacker_key" {
  user = aws_iam_user.attacker.name
}
