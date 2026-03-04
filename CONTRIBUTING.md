# Contributing Guide

## How to Contribute

We welcome contributions! This guide explains how to add new challenges or improve existing ones.

## Adding a New Challenge

### 1. Create Challenge Directory Structure
```bash
mkdir -p challenges/07-new-challenge/{terraform,writeup}
```

### 2. Create Terraform Files

**terraform/versions.tf**
```hcl
terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**terraform/variables.tf**
```hcl
variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}
```

**terraform/main.tf**
- Include clear comments marking vulnerabilities
- Use `random_id` for unique resource names
- Set `force_destroy = true` for easy cleanup

**terraform/outputs.tf**
- Export all necessary information for exploitation
- Mark sensitive outputs with `sensitive = true`

### 3. Create Writeup

**writeup/README.md** should include:
- Challenge objective
- Setup instructions
- 3+ hints (in collapsible sections)
- Complete solution with commands
- Flag format
- MITRE ATT&CK mapping
- Remediation steps
- Detection rules
- Further reading links

### 4. Update Main README

Add entry to challenges table:
```markdown
| 07 | [Challenge Name](challenges/07-new-challenge/writeup/README.md) | 🟢 Easy | MITRE Tactic | Category |
```

### 5. Test Thoroughly

```bash
cd challenges/07-new-challenge/terraform
terraform init
terraform plan
terraform apply
# Test exploitation
terraform destroy
```

## Code Standards

### Terraform
- Use descriptive resource names
- Add comments for vulnerabilities
- Follow [Terraform style guide](https://developer.hashicorp.com/terraform/language/style)
- Use `force_destroy = true` for test resources
- Include `random_id` for uniqueness

### Documentation
- Use clear, concise language
- Include code examples
- Add security context (MITRE ATT&CK)
- Explain the "why" not just the "how"

### Security
- Never commit real credentials
- Use placeholder values in examples
- Document all intentional vulnerabilities
- Include remediation guidance

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b add-challenge-07`
3. Make your changes
4. Test thoroughly
5. Update README.md and SETUP.md if needed
6. Submit a pull request with:
   - Clear description of changes
   - Testing results
   - Any new prerequisites

## Reporting Issues

Found a bug or have a suggestion?

1. Check existing issues first
2. Create a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce (if applicable)
   - Expected vs actual behavior
   - Environment details (OS, Terraform version, etc.)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn
- Report security issues privately

## Questions?

- Check existing documentation
- Review similar challenges
- Open a discussion issue
- Contact the maintainers

Thank you for contributing! 🙏
