# 🚩 Cloud Security CTF Challenges

> Intentionally vulnerable AWS environments to practice cloud security attack and defense techniques. Each challenge deploys real infrastructure via Terraform — find the vulnerability, exploit it, then learn how to fix it.

**Author:** Ankita Dixit | AWS Certified Security Specialist

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/master-coder1998/cloud-security-ctf/graphs/commit-activity)
[![AWS](https://img.shields.io/badge/AWS-Certified-FF9900.svg)](https://aws.amazon.com/certification/)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3-623CE4.svg)](https://www.terraform.io/)

> ⚠️ **WARNING:** These environments are intentionally insecure. Deploy only in a dedicated, isolated AWS account. Never in production.

---

## 🚀 Quick Start

- **[00_START_HERE.md](00_START_HERE.md)** - Quick navigation guide
- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Complete project guide
- **[SETUP.md](SETUP.md)** - Prerequisites & AWS account setup
- **[LEARNING_PATH.md](LEARNING_PATH.md)** - 7 learning paths (beginner/intermediate/advanced)
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Common commands & workflows
- **[FAQ.md](FAQ.md)** - 50+ frequently asked questions
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Problem-solving guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Find what you need

---

## 📊 What You'll Learn

- ✅ AWS security fundamentals
- ✅ Real-world vulnerability exploitation
- ✅ Security remediation techniques
- ✅ MITRE ATT&CK framework mapping
- ✅ Infrastructure-as-Code best practices
- ✅ Cloud security architecture
- ✅ Incident response procedures

---

## 🎯 Challenges Overview

| # | Challenge | Difficulty | MITRE Tactic | Category |
|---|---|---|---|---|
| 01 | [Misconfigured S3 Bucket](challenges/01-misconfigured-s3/writeup/README.md) | 🟢 Easy | Discovery / Exfiltration | Storage |
| 02 | [Overprivileged IAM Role](challenges/02-overprivileged-iam/writeup/README.md) | 🟡 Medium | Privilege Escalation | Identity |
| 03 | [Exposed EC2 Metadata](challenges/03-ec2-metadata/writeup/README.md) | 🟡 Medium | Credential Access | Compute |
| 04 | [Secrets in Environment Variables](challenges/04-secrets-in-env/writeup/README.md) | 🟢 Easy | Credential Access | Secrets |
| 05 | [Insecure Lambda Function](challenges/05-insecure-lambda/writeup/README.md) | 🔴 Hard | Execution / Exfiltration | Serverless |
| 06 | [Publicly Accessible RDS](challenges/06-public-rds/writeup/README.md) | 🟡 Medium | Discovery / Exfiltration | Database |

---

## ⚡ Quick Start (5 minutes)

```bash
# 1. Clone repository
git clone https://github.com/master-coder1998/cloud-security-ctf
cd cloud-security-ctf

# 2. Read setup guide
cat SETUP.md

# 3. Deploy first challenge
cd challenges/01-misconfigured-s3/terraform
terraform init && terraform apply

# 4. Exploit vulnerability
aws s3 ls s3://<bucket-name> --recursive --no-sign-request

# 5. Cleanup
terraform destroy
```

---

## 📋 Prerequisites

- **AWS CLI** (v2.x or later)
- **Terraform** (>= 1.3)
- **Python** (3.8+)
- **Git**
- **MySQL client** (for Challenge 06)
- **Dedicated AWS account** (never use production)

---

## 💰 Cost Estimate

| Challenge | Resource | Cost/Day |
|-----------|----------|----------|
| 01 | S3 Bucket | $0.10 |
| 02 | IAM + S3 | $0.15 |
| 03 | EC2 + S3 | $0.50 |
| 04 | Lambda | $0.05 |
| 05 | Lambda + S3 | $0.10 |
| 06 | RDS + VPC | $1.50 |
| **Total** | **All 6** | **~$2.40/day** |

**Estimated total cost for all challenges: ~$5-$10 if run sequentially**

> 💡 Always destroy resources after each challenge: `terraform destroy`

---

## 🏗️ Project Structure

```
cloud-security-ctf/
├── 📖 Documentation
│   ├── README.md                    # Main entry point
│   ├── 00_START_HERE.md             # Quick navigation
│   ├── PROJECT_OVERVIEW.md          # Complete guide
│   ├── SETUP.md                     # Prerequisites & setup
│   ├── LEARNING_PATH.md             # 7 learning paths
│   ├── QUICK_REFERENCE.md           # Common commands
│   ├── FAQ.md                       # 50+ Q&A
│   ├── TROUBLESHOOTING.md           # Problem solving
│   ├── CONTRIBUTING.md              # Contribution guide
│   ├── DOCUMENTATION_INDEX.md       # Navigation
│   ├── PROFESSIONAL_SUMMARY.md      # Enhancement summary
│   └── IMPROVEMENTS.md              # Infrastructure improvements
│
├── 🎯 Challenges (6 total)
│   ├── 01-misconfigured-s3/
│   │   ├── terraform/               # Vulnerable infrastructure
│   │   └── writeup/README.md        # Solution & hints
│   ├── 02-overprivileged-iam/
│   ├── 03-ec2-metadata/
│   ├── 04-secrets-in-env/
│   ├── 05-insecure-lambda/
│   └── 06-public-rds/
│
├── 📚 Resources
│   └── docs/aws-security-resources.md
│
└── ⚙️ Configuration
    └── .gitignore
```

---

## 🎓 Learning Outcomes

### By Challenge
| Challenge | Primary Skills | Time |
|-----------|---|---|
| 01 | S3 security, data exfiltration | 30 min |
| 02 | IAM policies, privilege escalation | 60 min |
| 03 | EC2 metadata, SSRF attacks | 90 min |
| 04 | Lambda security, secrets | 45 min |
| 05 | Lambda RCE, code injection | 120 min |
| 06 | RDS security, database access | 120 min |

### By Completion
- ✅ Understand AWS security fundamentals
- ✅ Identify common misconfigurations
- ✅ Exploit real-world vulnerabilities
- ✅ Implement security remediation
- ✅ Map attacks to MITRE ATT&CK
- ✅ Apply AWS security best practices

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## ⚖️ Legal & Ethics

These challenges are for **educational purposes only**. Only deploy in AWS accounts you own. Do not attempt these techniques against systems you don't have explicit permission to test.

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 📞 Support

- **Questions?** Check [FAQ.md](FAQ.md)
- **Issues?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Getting started?** Read [SETUP.md](SETUP.md)
- **Need guidance?** Follow [LEARNING_PATH.md](LEARNING_PATH.md)

---

*Maintained by Ankita Dixit | AWS Certified Security Specialist*

*Last updated: March 2026*
