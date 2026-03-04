# Setup Guide

## Prerequisites

### Required Tools
- **AWS CLI** (v2.x or later)
  ```bash
  # Verify installation
  aws --version
  ```
- **Terraform** (v1.3 or later)
  ```bash
  # Verify installation
  terraform version
  ```
- **Python** (3.8+)
  ```bash
  python3 --version
  ```
- **Git**
  ```bash
  git --version
  ```

### Challenge-Specific Requirements
- **Challenge 06 (RDS)**: MySQL client
  ```bash
  # macOS
  brew install mysql-client
  
  # Ubuntu/Debian
  sudo apt-get install mysql-client
  
  # Windows (via Chocolatey)
  choco install mysql
  ```

## AWS Account Setup

### 1. Create a Dedicated AWS Account
- Use AWS Organizations to create a new member account
- Or create a standalone AWS account at https://aws.amazon.com
- **Never use your production account**

### 2. Configure AWS CLI
```bash
aws configure
# Enter:
# AWS Access Key ID: <your_access_key>
# AWS Secret Access Key: <your_secret_key>
# Default region: us-east-1
# Default output format: json
```

### 3. Verify Access
```bash
aws sts get-caller-identity
# Should return your account ID, user ARN, etc.
```

### 4. Set Up IAM User (Optional but Recommended)
Create a dedicated IAM user for CTF challenges:
```bash
aws iam create-user --user-name ctf-user
aws iam attach-user-policy --user-name ctf-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name ctf-user
```

## Deployment Workflow

### Deploy a Challenge
```bash
cd challenges/01-misconfigured-s3/terraform

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy the vulnerable environment
terraform apply

# Save the outputs (you'll need them for exploitation)
terraform output
```

### Exploit the Challenge
1. Read the challenge's `writeup/README.md`
2. Follow the hints and exploitation steps
3. Find the flag

### Clean Up
```bash
# Destroy all resources
terraform destroy

# Verify deletion
aws s3 ls  # Should not show your CTF buckets
aws ec2 describe-instances  # Should not show your CTF instances
```

## Cost Management

### Estimated Costs
| Challenge | Resource | Estimated Cost/Day |
|-----------|----------|-------------------|
| 01 | S3 Bucket | $0.10 |
| 02 | IAM + S3 | $0.15 |
| 03 | EC2 + S3 | $0.50 |
| 04 | Lambda | $0.05 |
| 05 | Lambda + S3 | $0.10 |
| 06 | RDS + VPC | $1.50 |

### Cost Optimization Tips
- Deploy one challenge at a time
- Destroy immediately after completing
- Use `terraform destroy` to remove all resources
- Monitor your AWS bill: https://console.aws.amazon.com/billing

## Troubleshooting

### Terraform Init Fails
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Reinitialize
terraform init
```

### AWS CLI Authentication Error
```bash
# Verify credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

### Terraform Apply Fails with Permission Error
- Ensure your IAM user has sufficient permissions
- Check AWS CloudTrail for detailed error messages
- Verify region is correct: `aws configure get region`

### EC2 Instance Not Reachable (Challenge 03)
- Verify security group allows SSH: `aws ec2 describe-security-groups`
- Check instance is running: `aws ec2 describe-instances`
- Wait 2-3 minutes for instance to fully boot

### RDS Connection Timeout (Challenge 06)
- Verify RDS instance is available: `aws rds describe-db-instances`
- Check security group allows port 3306
- Ensure MySQL client is installed
- Wait 5-10 minutes for RDS to be fully available

### Lambda Function URL Not Working (Challenge 05)
- Verify function exists: `aws lambda list-functions`
- Check function URL is created: `aws lambda get-function-url-config --function-name <name>`
- Wait 1-2 minutes after deployment

## Security Best Practices

### During CTF Challenges
- ✅ Use a dedicated AWS account
- ✅ Use a dedicated IAM user
- ✅ Destroy resources immediately after use
- ✅ Monitor CloudTrail for unauthorized access
- ✅ Use VPC Flow Logs to monitor network traffic

### After CTF Challenges
- Delete the IAM user: `aws iam delete-user --user-name ctf-user`
- Delete access keys: `aws iam delete-access-key --user-name ctf-user --access-key-id <key>`
- Close the AWS account if it was created just for CTF

## Support

For issues or questions:
1. Check the challenge's `writeup/README.md`
2. Review AWS documentation: https://docs.aws.amazon.com
3. Check Terraform documentation: https://www.terraform.io/docs
4. Review CloudTrail logs for detailed error messages
