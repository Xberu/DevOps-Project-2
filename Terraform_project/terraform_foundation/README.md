# Terraform Foundation

Base Terraform stack with provider configuration and a sample S3 bucket resource.

## Overview

This stack defines Terraform and provider version constraints, configures the AWS provider for `us-east-1`, and provisions a test S3 bucket with a random suffix. It serves as a foundational example for provider setup and basic resource creation.

## Directory Structure

```
terraform_foundation/
└── terraform-manifests/
    ├── s1-versions.tf    # Terraform and provider version blocks
    ├── s2-s3bucket.tf    # Random string and S3 bucket resources
    └── s3-outputs.tf     # S3 bucket outputs
```

## Resources

| Resource | Name | Description |
|----------|------|-------------|
| `random_string` | `random` | 6-character lowercase alphanumeric suffix |
| `aws_s3_bucket` | `test_bucket` | S3 bucket named `devops-test-bucket-{suffix}` |

### Bucket Tags

| Tag Key | Value |
|---------|-------|
| `Name` | `my-test-bucket` |
| `Environment` | `Dev` |

## Outputs

| Output | Description |
|--------|-------------|
| `s3_bucket_name` | Name of the test S3 bucket |
| `s3_bucket_id` | ID of the test S3 bucket |
| `s3_bucket_arn` | ARN of the test S3 bucket |

## Provider Configuration

```hcl
terraform {
  required_version = ">= 1.15.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

The AWS region is hardcoded to `us-east-1` in the provider block. This stack does not define input variables.

## Usage

```bash
cd Terraform_project/terraform_foundation/terraform-manifests

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## State Storage

This stack uses local state by default (`terraform.tfstate` in the working directory). State files are excluded from version control via the project `.gitignore`.

To migrate to remote state, configure an S3 backend in `s1-versions.tf` after deploying the remote backend stack.

## Related Documentation

- [Remote Backend S3 Bucket](../remote-backend-s3bucket/README.md)
- [Terraform Project README](../README.md)
- [Project Root README](../../README.md)
