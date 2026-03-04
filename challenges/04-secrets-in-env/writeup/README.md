# Challenge 04: Secrets in Environment Variables

**Difficulty:** 🟢 Easy  
**Category:** Secrets Management  
**MITRE ATT&CK:** [T1552.001 - Unsecured Credentials: Credentials in Files](https://attack.mitre.org/techniques/T1552/001/)

---

## 🎯 Objective

You have credentials for a low-privilege IAM user with `lambda:GetFunctionConfiguration`. A Lambda function was deployed with secrets stored as plaintext environment variables. Extract the flag.

---

## 🌍 Setup

```bash
cd challenges/04-secrets-in-env/terraform
terraform init && terraform apply

aws configure --profile ctf-04
# Enter attacker credentials from terraform output
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
Lambda environment variables are stored in plaintext and are returned in the `GetFunctionConfiguration` API response.
</details>

<details>
<summary>Hint 2</summary>
Start by listing Lambda functions, then call `get-function-configuration` on the CTF function.
</details>

---

## ✅ Solution

```bash
# List functions
aws lambda list-functions --profile ctf-04 \
  --query 'Functions[?contains(FunctionName, `ctf-04`)].FunctionName'

# Read environment variables (and all secrets)
aws lambda get-function-configuration \
  --function-name <function_name> \
  --profile ctf-04 \
  --query 'Environment.Variables'
```

Output:
```json
{
  "DB_HOST": "prod-db.internal.example.com",
  "DB_PASSWORD": "Pr0d$ecretDBpass!",
  "STRIPE_API_KEY": "sk_live_abcdef1234567890",
  "JWT_SECRET": "my-super-secret-jwt-key",
  "FLAG": "CTF{plaintext_secrets_in_lambda_env}"
}
```

🚩 **Flag:** `CTF{plaintext_secrets_in_lambda_env}`

---

## 🔍 MITRE ATT&CK Mapping

| Field | Detail |
|---|---|
| Tactic | Credential Access |
| Technique | T1552.001 — Unsecured Credentials |
| Detection | CloudTrail: `GetFunctionConfiguration` calls, especially from non-CI/CD principals |

---

## 🛠️ Remediation

### Fix 1 — Use AWS Secrets Manager

```python
# In your Lambda function code
import boto3, json

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

def handler(event, context):
    secrets = get_secret('prod/myapp/db')
    db_password = secrets['password']
    # Never stored in env vars — fetched at runtime
```

### Fix 2 — Terraform secure version

```hcl
# Store in Secrets Manager instead
resource "aws_secretsmanager_secret" "db_creds" {
  name = "prod/myapp/db"
}

resource "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password  # passed via tfvars, never hardcoded
  })
}

# Lambda only gets the secret name in env vars — not the value
resource "aws_lambda_function" "secure" {
  environment {
    variables = {
      SECRET_NAME = aws_secretsmanager_secret.db_creds.name  # safe
    }
  }
}
```

### Fix 3 — Detect with CloudTrail

Create an EventBridge rule to alert on `GetFunctionConfiguration` calls:

```json
{
  "source": ["aws.lambda"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["GetFunctionConfiguration"],
    "userIdentity": {
      "type": ["IAMUser", "AssumedRole"]
    }
  }
}
```

---

## 📚 Further Reading

- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [Lambda Environment Variable Encryption](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html)
