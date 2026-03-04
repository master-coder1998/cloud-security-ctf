# Learning Path Guide

## Recommended Learning Progression

This guide helps you choose which challenges to tackle based on your experience level and learning goals.

---

## 🟢 Beginner Path (No AWS Experience)

**Goal:** Learn AWS fundamentals through security vulnerabilities

### Week 1: Storage & Secrets
1. **Challenge 01: Misconfigured S3 Bucket** (30 min)
   - Learn: S3 basics, public access, data exfiltration
   - Skills: AWS CLI, S3 operations
   - Prerequisites: None

2. **Challenge 04: Secrets in Environment Variables** (45 min)
   - Learn: Lambda basics, credential exposure
   - Skills: Lambda configuration, IAM permissions
   - Prerequisites: Challenge 01

### Week 2: Identity & Access
3. **Challenge 02: Overprivileged IAM Role** (60 min)
   - Learn: IAM policies, privilege escalation
   - Skills: IAM policy analysis, role assumption
   - Prerequisites: Challenge 01, 04

### Week 3: Compute & Metadata
4. **Challenge 03: Exposed EC2 Metadata** (90 min)
   - Learn: EC2 metadata service, SSRF attacks
   - Skills: EC2 basics, HTTP requests, credential theft
   - Prerequisites: Challenge 01, 02

**Estimated Time:** 4-5 hours  
**Outcome:** Understand core AWS security concepts

---

## 🟡 Intermediate Path (Some AWS Experience)

**Goal:** Master advanced exploitation techniques

### Start Here
1. **Challenge 02: Overprivileged IAM Role** (60 min)
   - Learn: IAM policy analysis, privilege escalation
   - Skills: Policy evaluation, role assumption

2. **Challenge 03: Exposed EC2 Metadata** (90 min)
   - Learn: EC2 metadata, SSRF, credential theft
   - Skills: Network exploitation, credential usage

3. **Challenge 06: Publicly Accessible RDS** (120 min)
   - Learn: RDS security, database access, data exfiltration
   - Skills: Database connections, SQL queries
   - Prerequisites: MySQL client installed

### Then Progress To
4. **Challenge 05: Insecure Lambda Function** (120 min)
   - Learn: Lambda security, code injection, RCE
   - Skills: Lambda exploitation, AWS SDK usage
   - Prerequisites: Challenge 02, 03

**Estimated Time:** 6-8 hours  
**Outcome:** Advanced exploitation and privilege escalation

---

## 🔴 Advanced Path (AWS Security Expert)

**Goal:** Master all attack vectors and remediation

### Recommended Order
1. **Challenge 05: Insecure Lambda Function** (120 min)
   - Learn: Lambda RCE, code injection, S3 exfiltration
   - Skills: Advanced exploitation, AWS SDK

2. **Challenge 06: Publicly Accessible RDS** (120 min)
   - Learn: Database security, network exposure
   - Skills: Database exploitation, data extraction

3. **Challenge 02: Overprivileged IAM Role** (60 min)
   - Learn: Policy analysis, privilege escalation
   - Skills: IAM policy evaluation

4. **Challenge 03: Exposed EC2 Metadata** (90 min)
   - Learn: Metadata exploitation, SSRF chains
   - Skills: Advanced exploitation techniques

5. **Challenge 01: Misconfigured S3 Bucket** (30 min)
   - Learn: S3 security, data exfiltration
   - Skills: S3 operations, public access

6. **Challenge 04: Secrets in Environment Variables** (45 min)
   - Learn: Credential exposure, Lambda security
   - Skills: Configuration analysis

**Estimated Time:** 8-10 hours  
**Outcome:** Complete mastery of all attack vectors

---

## 🎯 Role-Based Learning Paths

### For Cloud Architects
**Focus:** Infrastructure security, access control, compliance

1. Challenge 02 - IAM privilege escalation
2. Challenge 06 - Database security
3. Challenge 03 - EC2 metadata exposure
4. Challenge 01 - S3 misconfiguration

**Time:** 4-5 hours

### For Security Engineers
**Focus:** Threat detection, incident response, remediation

1. Challenge 05 - Lambda RCE
2. Challenge 03 - EC2 metadata exploitation
3. Challenge 02 - IAM privilege escalation
4. Challenge 06 - Database exposure
5. Challenge 01 - S3 exfiltration
6. Challenge 04 - Credential exposure

**Time:** 8-10 hours

### For DevOps Engineers
**Focus:** Infrastructure as Code, deployment security, automation

1. Challenge 01 - S3 configuration
2. Challenge 04 - Environment variables
3. Challenge 02 - IAM policies
4. Challenge 03 - EC2 security groups
5. Challenge 06 - RDS configuration
6. Challenge 05 - Lambda security

**Time:** 6-8 hours

### For Developers
**Focus:** Application security, credential management, code security

1. Challenge 04 - Secrets in environment variables
2. Challenge 05 - Lambda code injection
3. Challenge 01 - Data exposure
4. Challenge 02 - Permission escalation
5. Challenge 03 - Metadata exploitation
6. Challenge 06 - Database security

**Time:** 7-9 hours

---

## 📚 Topic-Based Learning Paths

### Storage Security
1. Challenge 01 - Misconfigured S3
2. Challenge 06 - RDS exposure

**Time:** 2-3 hours

### Identity & Access Management
1. Challenge 02 - Overprivileged IAM
2. Challenge 04 - Secrets exposure
3. Challenge 03 - Credential theft

**Time:** 3-4 hours

### Compute Security
1. Challenge 03 - EC2 metadata
2. Challenge 05 - Lambda RCE
3. Challenge 04 - Environment variables

**Time:** 4-5 hours

### Data Exfiltration
1. Challenge 01 - S3 data theft
2. Challenge 06 - Database extraction
3. Challenge 05 - Lambda data access

**Time:** 3-4 hours

---

## 🚀 Accelerated Path (1 Day)

**Goal:** Quick overview of all challenges

```
Morning (4 hours):
- Challenge 01: Misconfigured S3 (30 min)
- Challenge 04: Secrets in Env (45 min)
- Challenge 02: Overprivileged IAM (60 min)
- Challenge 03: EC2 Metadata (90 min)

Afternoon (4 hours):
- Challenge 05: Insecure Lambda (120 min)
- Challenge 06: Public RDS (120 min)
```

---

## 📖 Learning Objectives by Challenge

### Challenge 01: Misconfigured S3
- ✅ S3 bucket configuration
- ✅ Public access controls
- ✅ Data exfiltration
- ✅ AWS CLI usage

### Challenge 02: Overprivileged IAM
- ✅ IAM policy analysis
- ✅ Privilege escalation
- ✅ Role assumption
- ✅ Least privilege principle

### Challenge 03: Exposed EC2 Metadata
- ✅ EC2 metadata service
- ✅ SSRF attacks
- ✅ Credential theft
- ✅ IMDSv1 vs IMDSv2

### Challenge 04: Secrets in Environment Variables
- ✅ Credential exposure
- ✅ Lambda configuration
- ✅ Secrets management
- ✅ AWS Secrets Manager

### Challenge 05: Insecure Lambda Function
- ✅ Lambda security
- ✅ Code injection
- ✅ Remote code execution
- ✅ S3 data access

### Challenge 06: Publicly Accessible RDS
- ✅ RDS security
- ✅ Database access
- ✅ Network exposure
- ✅ Data extraction

---

## 💡 Tips for Success

### Before Starting
- [ ] Read the challenge objective
- [ ] Review prerequisites
- [ ] Ensure AWS account is ready
- [ ] Check cost estimates

### During Challenge
- [ ] Read hints progressively (don't skip to solution)
- [ ] Take notes on what you learn
- [ ] Try different approaches
- [ ] Document your findings

### After Challenge
- [ ] Review the complete solution
- [ ] Understand the remediation
- [ ] Study the MITRE ATT&CK mapping
- [ ] Destroy resources immediately

### General Tips
- Start with beginner challenges
- Don't skip hints - they teach important concepts
- Repeat challenges to reinforce learning
- Modify challenges to deepen understanding
- Share your progress with others

---

## 🎓 Certification Alignment

These challenges align with:
- **AWS Certified Security - Specialty**
- **AWS Certified Solutions Architect - Professional**
- **GIAC Security Essentials (GSEC)**
- **Certified Ethical Hacker (CEH)**

---

## Next Steps After Challenges

1. **Explore Real-World Scenarios**
   - Review AWS Well-Architected Framework
   - Study AWS Security Best Practices
   - Analyze real security incidents

2. **Deepen Your Knowledge**
   - Take AWS security courses
   - Read security whitepapers
   - Join security communities

3. **Practice More**
   - Try other CTF platforms (flaws.cloud, CloudGoat)
   - Build secure AWS applications
   - Conduct security audits

4. **Get Certified**
   - AWS Certified Security - Specialty
   - AWS Certified Solutions Architect - Professional

---

## Resources by Challenge

### Challenge 01
- [AWS S3 Security](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security.html)
- [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)

### Challenge 02
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [IAM Policy Evaluation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)

### Challenge 03
- [EC2 Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)
- [IMDSv2 Security](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)

### Challenge 04
- [Lambda Security](https://docs.aws.amazon.com/lambda/latest/dg/security.html)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)

### Challenge 05
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Lambda Function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html)

### Challenge 06
- [RDS Security](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.html)
- [RDS Encryption](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html)

---

## Questions?

- Check `FAQ.md` for common questions
- Review `QUICK_REFERENCE.md` for commands
- See `SETUP.md` for setup help
- Check challenge `writeup/README.md` for specific help

Happy learning! 🎓
