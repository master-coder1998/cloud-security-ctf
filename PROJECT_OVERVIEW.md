# Project Overview

## What is Cloud Security CTF?

Cloud Security CTF is a comprehensive, hands-on learning platform for AWS cloud security. It provides 6 intentionally vulnerable AWS environments that teach real-world security concepts through practical exploitation and remediation.

**Key Features:**
- 🎯 6 real-world vulnerability scenarios
- 🏗️ Infrastructure-as-Code (Terraform) for easy deployment
- 📚 Detailed writeups with hints and solutions
- 🔐 MITRE ATT&CK framework mapping
- 💰 Low-cost ($5-$10 total)
- 🚀 Beginner to advanced difficulty levels

---

## Project Structure

```
cloud-security-ctf/
│
├── 📖 Documentation
│   ├── README.md                 # Main entry point
│   ├── SETUP.md                  # Setup & prerequisites
│   ├── QUICK_REFERENCE.md        # Common commands
│   ├── FAQ.md                    # Frequently asked questions
│   ├── LEARNING_PATH.md          # Recommended learning progression
│   ├── CONTRIBUTING.md           # How to contribute
│   ├── IMPROVEMENTS.md           # Infrastructure improvements
│   └── PROJECT_OVERVIEW.md       # This file
│
├── 🎯 Challenges (6 total)
│   ├── 01-misconfigured-s3/
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

## The 6 Challenges

### 🟢 Challenge 01: Misconfigured S3 Bucket
**Difficulty:** Easy | **Time:** 30 min | **Cost:** $0.10/day

**Vulnerability:** Public S3 bucket with sensitive data  
**Attack:** Data exfiltration via AWS CLI  
**Learning:** S3 security, public access controls, data exposure  
**MITRE:** T1530 - Data from Cloud Storage

**Key Concepts:**
- S3 bucket configuration
- Public access controls
- AWS CLI operations
- Data exfiltration

---

### 🟡 Challenge 02: Overprivileged IAM Role
**Difficulty:** Medium | **Time:** 60 min | **Cost:** $0.15/day

**Vulnerability:** IAM role with excessive permissions  
**Attack:** Privilege escalation via role assumption  
**Learning:** IAM policies, least privilege, privilege escalation  
**MITRE:** T1548 - Abuse Elevation Control Mechanism

**Key Concepts:**
- IAM policy analysis
- Privilege escalation
- Role assumption
- Least privilege principle

---

### 🟡 Challenge 03: Exposed EC2 Metadata
**Difficulty:** Medium | **Time:** 90 min | **Cost:** $0.50/day

**Vulnerability:** IMDSv1 enabled on EC2 instance  
**Attack:** SSRF to steal IAM credentials  
**Learning:** EC2 metadata service, SSRF attacks, credential theft  
**MITRE:** T1552 - Unsecured Credentials

**Key Concepts:**
- EC2 metadata service
- SSRF vulnerabilities
- Credential theft
- IMDSv1 vs IMDSv2

---

### 🟢 Challenge 04: Secrets in Environment Variables
**Difficulty:** Easy | **Time:** 45 min | **Cost:** $0.05/day

**Vulnerability:** Credentials stored in Lambda environment variables  
**Attack:** Configuration enumeration to extract secrets  
**Learning:** Credential exposure, secrets management, Lambda security  
**MITRE:** T1552 - Unsecured Credentials

**Key Concepts:**
- Lambda configuration
- Credential exposure
- Secrets management
- AWS Secrets Manager

---

### 🔴 Challenge 05: Insecure Lambda Function
**Difficulty:** Hard | **Time:** 120 min | **Cost:** $0.10/day

**Vulnerability:** Lambda function with code injection and public URL  
**Attack:** RCE via eval() to access S3  
**Learning:** Lambda security, code injection, RCE, data exfiltration  
**MITRE:** T1059 - Command and Scripting Interpreter

**Key Concepts:**
- Lambda security
- Code injection
- Remote code execution
- S3 data access
- AWS SDK usage

---

### 🟡 Challenge 06: Publicly Accessible RDS
**Difficulty:** Medium | **Time:** 120 min | **Cost:** $1.50/day

**Vulnerability:** RDS instance publicly accessible with weak security  
**Attack:** Direct database connection to extract data  
**Learning:** RDS security, database access, data extraction  
**MITRE:** T1530 - Data from Cloud Storage

**Key Concepts:**
- RDS security
- Database access
- Network exposure
- Data extraction
- SQL queries

---

## Learning Outcomes

### By Challenge
| Challenge | Primary Skills | Secondary Skills |
|-----------|---|---|
| 01 | S3 security, AWS CLI | Data exfiltration |
| 02 | IAM policies, privilege escalation | Role assumption |
| 03 | EC2 metadata, SSRF | Credential theft |
| 04 | Lambda security, secrets | Configuration analysis |
| 05 | Lambda RCE, code injection | S3 access, AWS SDK |
| 06 | RDS security, database access | Data extraction |

### By Completion
- ✅ Understand AWS security fundamentals
- ✅ Identify common misconfigurations
- ✅ Exploit real-world vulnerabilities
- ✅ Implement security remediation
- ✅ Map attacks to MITRE ATT&CK framework
- ✅ Apply AWS security best practices

---

## Getting Started

### Quick Start (5 minutes)
```bash
# 1. Clone repository
git clone https://github.com/master-coder1998/cloud-security-ctf
cd cloud-security-ctf

# 2. Read documentation
cat README.md

# 3. Follow setup guide
cat SETUP.md

# 4. Choose learning path
cat LEARNING_PATH.md
```

### First Challenge (30 minutes)
```bash
# 1. Deploy Challenge 01
cd challenges/01-misconfigured-s3/terraform
terraform init && terraform apply

# 2. Read writeup
cat ../writeup/README.md

# 3. Exploit vulnerability
aws s3 ls s3://<bucket-name> --recursive --no-sign-request

# 4. Find flag
aws s3 cp s3://<bucket-name>/internal/config/app-secrets.json - --no-sign-request

# 5. Cleanup
terraform destroy
```

---

## Documentation Guide

### For Different Users

**New to AWS?**
1. Start with `README.md`
2. Follow `SETUP.md` for prerequisites
3. Use `LEARNING_PATH.md` - Beginner Path
4. Reference `QUICK_REFERENCE.md` for commands

**AWS Experience?**
1. Review `README.md` overview
2. Check `LEARNING_PATH.md` - Intermediate Path
3. Use `QUICK_REFERENCE.md` for commands
4. Reference challenge writeups as needed

**Security Expert?**
1. Skim `README.md`
2. Follow `LEARNING_PATH.md` - Advanced Path
3. Use `QUICK_REFERENCE.md` for efficiency
4. Consider `CONTRIBUTING.md` for adding challenges

**Want to Contribute?**
1. Read `CONTRIBUTING.md`
2. Review existing challenges
3. Follow code standards
4. Submit pull request

**Have Questions?**
1. Check `FAQ.md` first
2. Review `SETUP.md` for setup issues
3. Check challenge `writeup/README.md`
4. Open GitHub issue

---

## Key Features

### 🏗️ Infrastructure as Code
- Terraform for reproducible deployments
- Organized file structure (versions.tf, variables.tf, outputs.tf, main.tf)
- Easy to modify and extend
- Version-controlled

### 📚 Comprehensive Documentation
- Setup guides with troubleshooting
- Learning paths for different experience levels
- Quick reference for common commands
- FAQ for common questions
- Contributing guidelines

### 🔐 Real-World Vulnerabilities
- Based on actual AWS misconfigurations
- MITRE ATT&CK framework mapping
- Exploitation techniques
- Remediation guidance

### 💰 Cost-Effective
- ~$5-$10 total for all challenges
- ~$0.50-$2.00 per challenge per day
- Easy cleanup with `terraform destroy`
- Cost monitoring tips included

### 🎓 Educational Focus
- Progressive difficulty levels
- Hints and solutions provided
- Security best practices included
- Real-world context

---

## Technology Stack

### Infrastructure
- **AWS Services:** S3, IAM, EC2, Lambda, RDS, VPC
- **Infrastructure as Code:** Terraform >= 1.3
- **AWS Provider:** ~> 5.0

### Tools
- **AWS CLI:** v2.x or later
- **Python:** 3.8+
- **Git:** Version control
- **MySQL Client:** For Challenge 06

### Documentation
- **Markdown:** All documentation
- **GitHub:** Repository hosting
- **MITRE ATT&CK:** Security framework

---

## Security & Ethics

### ⚠️ Important Warnings
- **Only use on your own AWS account**
- **Never use on production systems**
- **Never attempt on systems without permission**
- **For educational purposes only**

### Best Practices
- Use dedicated test AWS account
- Destroy resources immediately after use
- Monitor AWS billing
- Use IAM users with limited permissions
- Enable CloudTrail for audit logging

---

## Project Statistics

| Metric | Value |
|--------|-------|
| Total Challenges | 6 |
| Difficulty Levels | 3 (Easy, Medium, Hard) |
| AWS Services Covered | 8+ |
| MITRE Techniques | 5+ |
| Documentation Pages | 8 |
| Estimated Learning Time | 8-10 hours |
| Total Cost | $5-$10 |

---

## Roadmap

### Current (v1.0)
- ✅ 6 core challenges
- ✅ Comprehensive documentation
- ✅ Terraform infrastructure
- ✅ Writeups with solutions

### Future Enhancements
- 🔄 Additional challenges (07-12)
- 🔄 Video walkthroughs
- 🔄 Automated testing
- 🔄 CI/CD integration
- 🔄 Community contributions
- 🔄 Advanced scenarios

---

## Community & Support

### Getting Help
1. **Documentation:** Check README, SETUP, FAQ, LEARNING_PATH
2. **Quick Reference:** Use QUICK_REFERENCE.md for commands
3. **Challenge Help:** Review challenge writeup/README.md
4. **GitHub Issues:** Report bugs or ask questions
5. **Discussions:** Share experiences with others

### Contributing
- Add new challenges
- Improve documentation
- Fix bugs
- Share feedback
- Report security issues

See `CONTRIBUTING.md` for details.

---

## Resources

### AWS Documentation
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

### Security Frameworks
- [MITRE ATT&CK](https://attack.mitre.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

### Learning Platforms
- [flaws.cloud](http://flaws.cloud) - AWS CTF
- [CloudGoat](https://github.com/RhinoSecurityLabs/cloudgoat) - AWS scenarios
- [AWSGoat](https://github.com/ine-labs/AWSGoat) - AWS vulnerabilities

### Tools
- [Prowler](https://github.com/prowler-cloud/prowler) - AWS security assessment
- [ScoutSuite](https://github.com/nccgroup/ScoutSuite) - Multi-cloud auditing
- [Pacu](https://github.com/RhinoSecurityLabs/pacu) - AWS exploitation

---

## License & Attribution

**Author:** Ankita Dixit | AWS Certified Security Specialist

**Educational Use:** These challenges are for learning purposes only.

**Disclaimer:** Use only on systems you own or have explicit permission to test.

---

## Quick Links

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Main entry point |
| [SETUP.md](SETUP.md) | Setup & prerequisites |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Common commands |
| [FAQ.md](FAQ.md) | Frequently asked questions |
| [LEARNING_PATH.md](LEARNING_PATH.md) | Learning progression |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [IMPROVEMENTS.md](IMPROVEMENTS.md) | Infrastructure changes |

---

## Next Steps

1. **Read:** Start with `README.md`
2. **Setup:** Follow `SETUP.md`
3. **Learn:** Choose path in `LEARNING_PATH.md`
4. **Deploy:** Use `QUICK_REFERENCE.md`
5. **Exploit:** Follow challenge writeups
6. **Contribute:** See `CONTRIBUTING.md`

---

**Happy Learning! 🚀**

For questions or feedback, open an issue on GitHub or check the FAQ.
