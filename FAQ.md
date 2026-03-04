# Frequently Asked Questions (FAQ)

## General Questions

### Q: What is this project?
A: Cloud Security CTF is a collection of 6 intentionally vulnerable AWS environments designed to teach cloud security concepts through hands-on exploitation and remediation.

### Q: Who should use this?
A: Security professionals, cloud engineers, developers, and anyone learning AWS security. No prior CTF experience required.

### Q: Is this legal?
A: Yes, for educational purposes on your own AWS account. Never attempt these techniques on systems you don't own or have permission to test.

### Q: How long does each challenge take?
A: 
- Easy challenges: 15-30 minutes
- Medium challenges: 30-60 minutes
- Hard challenges: 1-2 hours

### Q: Can I do challenges in any order?
A: Yes, each challenge is independent. Start with Challenge 01 if you're new to CTFs.

---

## Setup & Deployment

### Q: Do I need an AWS account?
A: Yes, a dedicated test account. Never use production. Create one at https://aws.amazon.com

### Q: How much will this cost?
A: ~$5-$10 total if you run all challenges sequentially and destroy resources immediately after each one.

### Q: How do I avoid high costs?
A: 
- Destroy resources immediately after completing: `terraform destroy`
- Run one challenge at a time
- Set up AWS Budgets alerts
- Monitor your bill regularly

### Q: What if I forget to destroy resources?
A: 
```bash
# Destroy all challenges at once
for dir in challenges/*/terraform; do
  cd "$dir"
  terraform destroy -auto-approve
  cd ../../..
done
```

### Q: Can I run multiple challenges simultaneously?
A: Yes, but costs will multiply. Not recommended for beginners.

### Q: What if terraform init fails?
A: 
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Q: How do I know if deployment succeeded?
A: 
```bash
terraform output
# Should show all outputs without errors
```

---

## Exploitation

### Q: I'm stuck on a challenge. What should I do?
A: 
1. Read the challenge's `writeup/README.md`
2. Start with Hint 1, then Hint 2, etc.
3. Review the solution section
4. Check AWS documentation

### Q: Can I see the solution before trying?
A: Yes, but you'll learn more by trying first. The writeup is there to help when stuck.

### Q: What if I can't find the flag?
A: 
- Verify resources deployed: `aws s3 ls`, `aws ec2 describe-instances`
- Check the writeup for the exact flag format
- Ensure you're in the correct AWS region

### Q: How do I know I found the flag?
A: Each challenge has a specific flag format (e.g., `CTF{...}`). The writeup shows the exact format.

### Q: Can I modify the challenge to make it easier/harder?
A: Yes! Edit the Terraform code and redeploy. This is a great way to learn.

---

## AWS & Terraform

### Q: What AWS services are used?
A: S3, IAM, EC2, Lambda, RDS, VPC, Security Groups, and more.

### Q: Do I need AWS experience?
A: Helpful but not required. Each challenge teaches AWS concepts.

### Q: What if I don't have AWS CLI configured?
A: 
```bash
aws configure
# Enter your access key, secret key, region, and output format
```

### Q: How do I verify my AWS credentials?
A: 
```bash
aws sts get-caller-identity
# Should return your account ID and user ARN
```

### Q: What Terraform version do I need?
A: >= 1.3. Check with `terraform version`

### Q: Can I use a different AWS region?
A: Yes, modify the `region` variable in `terraform/variables.tf`

### Q: What if a resource fails to create?
A: 
1. Check CloudTrail for detailed error messages
2. Verify IAM permissions
3. Check AWS service limits
4. Try again in a few minutes

---

## Troubleshooting

### Q: EC2 instance not reachable (Challenge 03)
A: 
- Wait 2-3 minutes for instance to boot
- Verify security group allows SSH
- Check instance is running: `aws ec2 describe-instances`

### Q: RDS connection timeout (Challenge 06)
A: 
- Wait 5-10 minutes for RDS to be ready
- Verify MySQL client installed: `mysql --version`
- Check security group allows port 3306
- Verify endpoint is correct: `terraform output rds_endpoint`

### Q: Lambda function URL not working (Challenge 05)
A: 
- Wait 1-2 minutes after deployment
- Verify function exists: `aws lambda list-functions`
- Check URL is created: `aws lambda get-function-url-config --function-name <name>`

### Q: S3 bucket access denied (Challenge 01)
A: 
- Verify bucket exists: `aws s3 ls`
- Use `--no-sign-request` flag for public access
- Check bucket policy: `aws s3api get-bucket-policy --bucket <name>`

### Q: Terraform state lock error
A: 
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### Q: Permission denied errors
A: 
- Verify IAM user has AdministratorAccess
- Check AWS credentials are correct
- Verify region is set correctly

---

## Learning & Resources

### Q: Where can I learn more about AWS security?
A: See `docs/aws-security-resources.md` for curated resources

### Q: What is MITRE ATT&CK?
A: A framework of adversary tactics and techniques. Each challenge maps to specific techniques.

### Q: How do I learn Terraform?
A: https://www.terraform.io/docs - Official documentation is excellent

### Q: Are there other AWS CTF projects?
A: Yes! Check out:
- flaws.cloud
- flaws2.cloud
- CloudGoat
- AWSGoat

### Q: Can I use this for training others?
A: Yes! It's perfect for workshops and training sessions. Just ensure everyone has their own AWS account.

---

## Advanced Questions

### Q: Can I add my own challenges?
A: Yes! See `CONTRIBUTING.md` for guidelines.

### Q: How do I modify a challenge?
A: Edit the Terraform code in `challenges/XX/terraform/main.tf` and redeploy.

### Q: Can I use this in a CI/CD pipeline?
A: Yes, but be careful with costs. Consider using AWS Lambda for automated testing.

### Q: How do I monitor costs?
A: 
- AWS Billing Dashboard: https://console.aws.amazon.com/billing
- Set up AWS Budgets alerts
- Use `aws ce get-cost-and-usage` CLI command

### Q: Can I use this with AWS Organizations?
A: Yes, create a member account for CTF challenges.

### Q: How do I backup my progress?
A: Take screenshots of flags and notes. Terraform state is automatically managed.

---

## Still Have Questions?

1. Check the challenge's `writeup/README.md`
2. Review `SETUP.md` for detailed setup instructions
3. Check `CONTRIBUTING.md` if you want to contribute
4. Open an issue on GitHub
5. Contact the maintainers

Happy learning! 🚀
