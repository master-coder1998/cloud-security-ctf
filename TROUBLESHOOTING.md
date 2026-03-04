# Troubleshooting Guide

## Common Issues & Solutions

### Installation & Setup

#### ❌ AWS CLI not found
```bash
# Error: command not found: aws

# Solution: Install AWS CLI v2
# macOS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify
aws --version
```

#### ❌ Terraform not found
```bash
# Error: command not found: terraform

# Solution: Install Terraform >= 1.3
# Visit: https://www.terraform.io/downloads

# macOS (Homebrew)
brew install terraform

# Ubuntu/Debian
wget https://apt.releases.hashicorp.com/gpg
sudo apt-key add gpg
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Verify
terraform version
```

#### ❌ Python not found
```bash
# Error: command not found: python3

# Solution: Install Python 3.8+
# macOS
brew install python@3.11

# Ubuntu/Debian
sudo apt-get install python3.11

# Windows
# Download from: https://www.python.org/downloads/

# Verify
python3 --version
```

#### ❌ MySQL client not found (Challenge 06)
```bash
# Error: command not found: mysql

# Solution: Install MySQL client
# macOS
brew install mysql-client

# Ubuntu/Debian
sudo apt-get install mysql-client

# Windows (Chocolatey)
choco install mysql

# Verify
mysql --version
```

---

### AWS Configuration

#### ❌ AWS credentials not configured
```bash
# Error: Unable to locate credentials

# Solution: Configure AWS CLI
aws configure
# Enter:
# AWS Access Key ID: <your_key>
# AWS Secret Access Key: <your_secret>
# Default region: us-east-1
# Default output format: json

# Verify
aws sts get-caller-identity
```

#### ❌ Invalid AWS credentials
```bash
# Error: InvalidClientTokenId or SignatureDoesNotMatch

# Solution: Verify credentials
aws sts get-caller-identity

# If error persists:
# 1. Check credentials in ~/.aws/credentials
# 2. Verify access key is not expired
# 3. Regenerate access key in IAM console
# 4. Reconfigure: aws configure
```

#### ❌ Wrong AWS region
```bash
# Error: Resource not found in region

# Solution: Check and set region
aws configure get region

# Set region
export AWS_REGION=us-east-1
aws configure set region us-east-1

# Or in Terraform
terraform apply -var="region=us-east-1"
```

#### ❌ Insufficient IAM permissions
```bash
# Error: User: arn:aws:iam::... is not authorized to perform: ...

# Solution: Ensure IAM user has AdministratorAccess
# 1. Go to IAM console
# 2. Select user
# 3. Add policy: AdministratorAccess
# 4. Wait 1-2 minutes for permissions to propagate
# 5. Try again
```

---

### Terraform Issues

#### ❌ Terraform init fails
```bash
# Error: Error initializing the backend

# Solution: Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Reinitialize
terraform init

# If still fails:
# 1. Check internet connection
# 2. Verify AWS credentials
# 3. Check Terraform version: terraform version
```

#### ❌ Terraform plan fails
```bash
# Error: Error: error reading S3 Bucket

# Solution: Check AWS credentials and permissions
aws sts get-caller-identity

# Verify IAM permissions
aws iam get-user

# Try again
terraform plan
```

#### ❌ Terraform apply fails
```bash
# Error: Error creating S3 bucket

# Solution: Check CloudTrail for detailed error
aws cloudtrail lookup-events --max-results 5

# Common causes:
# 1. S3 bucket name already exists (globally unique)
# 2. Insufficient IAM permissions
# 3. AWS service limit reached
# 4. Region not available

# Try again
terraform apply
```

#### ❌ Terraform state lock
```bash
# Error: Error acquiring the state lock

# Solution: Force unlock (use with caution)
terraform force-unlock <LOCK_ID>

# Or remove lock file
rm -f .terraform.tfstate.lock.info
```

#### ❌ Resource already exists
```bash
# Error: Error: resource already exists

# Solution: Import existing resource or destroy first
terraform destroy

# Or import
terraform import aws_s3_bucket.vulnerable <bucket-name>
```

---

### Challenge-Specific Issues

#### Challenge 01: S3 Bucket

**❌ Bucket not found**
```bash
# Error: NoSuchBucket

# Solution: Verify bucket exists
aws s3 ls

# Get bucket name from Terraform
cd challenges/01-misconfigured-s3/terraform
terraform output bucket_name

# Try again with correct name
aws s3 ls s3://<bucket-name> --recursive --no-sign-request
```

**❌ Access denied**
```bash
# Error: AccessDenied

# Solution: Verify bucket is public
aws s3api get-bucket-policy --bucket <bucket-name>

# Check public access block
aws s3api get-public-access-block --bucket <bucket-name>

# If blocked, redeploy challenge
terraform destroy && terraform apply
```

#### Challenge 03: EC2 Metadata

**❌ Instance not reachable**
```bash
# Error: Connection refused or timeout

# Solution: Wait for instance to boot
sleep 120

# Verify instance is running
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name]'

# Check security group
aws ec2 describe-security-groups --query 'SecurityGroups[].IpPermissions'

# Try again
curl http://<instance-ip>:8080
```

**❌ SSRF app not responding**
```bash
# Error: Connection refused on port 8080

# Solution: Wait for app to start
sleep 180

# Check instance logs
aws ec2 get-console-output --instance-id <instance-id>

# SSH into instance and check
ssh -i <key-file> ec2-user@<instance-ip>
ps aux | grep python
```

#### Challenge 04: Lambda

**❌ Function not found**
```bash
# Error: Function not found

# Solution: Verify function exists
aws lambda list-functions

# Get function name from Terraform
cd challenges/04-secrets-in-env/terraform
terraform output function_name

# Try again
aws lambda get-function-configuration --function-name <name>
```

**❌ Permission denied**
```bash
# Error: User is not authorized to perform: lambda:GetFunctionConfiguration

# Solution: Verify IAM permissions
aws iam get-user

# Ensure user has lambda:GetFunctionConfiguration
# Add policy if needed
```

#### Challenge 05: Lambda URL

**❌ Lambda URL not working**
```bash
# Error: 404 or connection refused

# Solution: Wait for URL to be created
sleep 60

# Verify URL exists
aws lambda get-function-url-config --function-name <name>

# Get URL from Terraform
cd challenges/05-insecure-lambda/terraform
terraform output lambda_url

# Try again
curl <lambda-url>
```

**❌ Lambda execution error**
```bash
# Error: 500 Internal Server Error

# Solution: Check Lambda logs
aws logs tail /aws/lambda/<function-name> --follow

# Or view in CloudWatch console
# https://console.aws.amazon.com/cloudwatch/

# Check function code
aws lambda get-function --function-name <name>
```

#### Challenge 06: RDS

**❌ RDS not ready**
```bash
# Error: Can't connect to MySQL server

# Solution: Wait for RDS to be ready
sleep 300

# Verify RDS is available
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus]'

# Check endpoint
cd challenges/06-public-rds/terraform
terraform output rds_endpoint

# Try again
mysql -h <endpoint> -u admin -p<password> appdb
```

**❌ MySQL client error**
```bash
# Error: command not found: mysql

# Solution: Install MySQL client
# macOS
brew install mysql-client

# Ubuntu/Debian
sudo apt-get install mysql-client

# Windows
choco install mysql

# Verify
mysql --version
```

**❌ Connection timeout**
```bash
# Error: Can't connect to MySQL server on '<endpoint>'

# Solution: Check security group
aws ec2 describe-security-groups --query 'SecurityGroups[].IpPermissions'

# Verify port 3306 is open
# Check RDS is publicly accessible
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,PubliclyAccessible]'

# Wait longer for RDS to be ready
sleep 600
```

---

### Cost & Billing

#### ❌ Unexpected charges
```bash
# Solution: Check what's running
aws s3 ls
aws ec2 describe-instances
aws lambda list-functions
aws rds describe-db-instances

# Destroy all resources
for dir in challenges/*/terraform; do
  cd "$dir"
  terraform destroy -auto-approve
  cd ../../..
done

# Verify nothing is running
aws s3 ls
aws ec2 describe-instances
```

#### ❌ High bill
```bash
# Solution: Set up cost alerts
# 1. Go to AWS Billing console
# 2. Create Budget
# 3. Set alert threshold
# 4. Destroy unused resources

# Check current costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

---

### Network & Connectivity

#### ❌ No internet connection
```bash
# Error: Unable to connect to AWS

# Solution: Check internet connection
ping 8.8.8.8

# Check DNS
nslookup aws.amazon.com

# Check AWS endpoint
curl https://sts.amazonaws.com

# Restart network
# macOS
sudo ifconfig en0 down
sudo ifconfig en0 up

# Linux
sudo systemctl restart networking
```

#### ❌ Firewall blocking
```bash
# Error: Connection refused or timeout

# Solution: Check firewall rules
# macOS
sudo pfctl -s all

# Linux
sudo iptables -L

# Windows
netsh advfirewall show allprofiles

# Allow AWS endpoints if blocked
```

---

### Git & Repository

#### ❌ Git clone fails
```bash
# Error: fatal: unable to access repository

# Solution: Check internet connection
ping github.com

# Verify SSH key (if using SSH)
ssh -T git@github.com

# Use HTTPS instead
git clone https://github.com/master-coder1998/cloud-security-ctf

# Or update remote
git remote set-url origin https://github.com/master-coder1998/cloud-security-ctf
```

#### ❌ Git push fails
```bash
# Error: Permission denied

# Solution: Check SSH key or credentials
ssh -T git@github.com

# Or use HTTPS with token
git remote set-url origin https://<token>@github.com/master-coder1998/cloud-security-ctf
```

---

### Performance Issues

#### ❌ Slow Terraform operations
```bash
# Solution: Increase parallelism
terraform apply -parallelism=10

# Or check AWS API rate limits
# Wait a few minutes and try again
```

#### ❌ Slow AWS CLI commands
```bash
# Solution: Check network connection
ping aws.amazon.com

# Use specific region
aws s3 ls --region us-east-1

# Check AWS service status
# https://status.aws.amazon.com/
```

---

### Debugging

#### Enable verbose logging

**Terraform**
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform.log
terraform apply
cat /tmp/terraform.log
```

**AWS CLI**
```bash
aws s3 ls --debug > /tmp/aws.log 2>&1
cat /tmp/aws.log
```

**Bash**
```bash
set -x  # Enable debug mode
# Run commands
set +x  # Disable debug mode
```

#### Check logs

**CloudTrail**
```bash
aws cloudtrail lookup-events --max-results 50
```

**CloudWatch**
```bash
aws logs describe-log-groups
aws logs tail /aws/lambda/<function-name> --follow
```

**EC2 System Log**
```bash
aws ec2 get-console-output --instance-id <instance-id>
```

---

### Getting Help

1. **Check Documentation**
   - README.md - Overview
   - SETUP.md - Setup help
   - FAQ.md - Common questions
   - QUICK_REFERENCE.md - Commands

2. **Check Challenge Writeup**
   - challenges/XX/writeup/README.md

3. **Check AWS Documentation**
   - https://docs.aws.amazon.com

4. **Check Terraform Documentation**
   - https://www.terraform.io/docs

5. **Open GitHub Issue**
   - Include error message
   - Include steps to reproduce
   - Include environment details

---

## Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| AWS credentials not found | `aws configure` |
| Terraform init fails | `rm -rf .terraform && terraform init` |
| Resource already exists | `terraform destroy && terraform apply` |
| Instance not reachable | Wait 2-3 minutes, check security group |
| RDS not ready | Wait 5-10 minutes |
| Lambda URL not working | Wait 1-2 minutes |
| High AWS bill | `terraform destroy` |
| Permission denied | Check IAM permissions |
| Connection timeout | Check security group, wait longer |

---

## Still Stuck?

1. **Review the challenge writeup** - challenges/XX/writeup/README.md
2. **Check FAQ.md** - Frequently asked questions
3. **Check QUICK_REFERENCE.md** - Common commands
4. **Enable debug logging** - See debugging section above
5. **Open GitHub issue** - Include all details

**Remember:** Most issues are related to AWS credentials, permissions, or timing. Take a break and try again! ☕

---

## Report a Bug

If you find a bug:

1. **Verify it's reproducible**
   - Try again in a fresh environment
   - Check if it's documented in FAQ

2. **Gather information**
   - Error message (full text)
   - Steps to reproduce
   - Environment (OS, Terraform version, AWS CLI version)
   - AWS region
   - Challenge number

3. **Open GitHub issue**
   - Clear title
   - Detailed description
   - Error logs
   - Steps to reproduce

4. **Be patient**
   - Maintainers will respond when available
   - Check for similar issues first

---

Happy troubleshooting! 🔧
