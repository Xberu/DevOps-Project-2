# Remote Backend S3 Bucket

Terraform stack that provisions an S3 bucket for storing Terraform state files remotely.

## Overview

This stack creates an S3 bucket with a unique name, enables bucket versioning, and configures the Terraform S3 backend for encrypted state storage with lock file support.

## Directory Structure

```
remote-backend-s3bucket/
└── terraform-manifests/
    ├── s1-versions.tf      # Terraform, provider, and backend configuration
    ├── s2-s3bucket.tf      # S3 bucket and versioning resources
    ├── s2-variables.tf     # Input variables
    └── s4-outputs.tf       # Output values
```

## Resources

| Resource | Name | Description |
|----------|------|-------------|
| `random_string` | `suffix` | 6-character lowercase alphanumeric suffix for bucket uniqueness |
| `aws_s3_bucket` | `tfstate_bucket` | S3 bucket for state storage |
| `aws_s3_bucket_versioning` | `tfstate_bucket_versioning` | Versioning enabled on the state bucket |

### Bucket Naming

Bucket name pattern:

```
tfstate-{environment_name}-{aws_region}-{random_suffix}
```

Example: `tfstate-dev-us-east-1-a1b2c3`

### Tags

| Tag Key | Value |
|---------|-------|
| `Name` | `tfstate-{environment_name}-{aws_region}` |
| `Environment` | Value of `environment_name` |
| `Project` | `remote-backend-for-devops-project` |
| `Purpose` | `Terraform state backend storage` |

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment_name` | string | `dev` | Environment identifier |
| `aws_region` | string | `us-east-1` | AWS region for the bucket |

## Outputs

| Output | Description |
|--------|-------------|
| `aws_region` | Deployed AWS region |
| `environment_name` | Environment name |
| `s3_bucket_name` | Name of the created S3 bucket |
| `s3_bucket_arn` | ARN of the S3 bucket |
| `s3_bucket_id` | ID of the S3 bucket |

## Backend Configuration

The S3 backend is defined in `s1-versions.tf`:

```hcl
backend "s3" {
  bucket       = "<bucket-name>"
  key          = "lockfile/dev/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
```

After the bucket is created, update the `bucket` attribute in the backend block to match the output `s3_bucket_name`.

## Usage

```bash
cd Terraform_project/remote-backend-s3bucket/terraform-manifests

terraform init
terraform validate
terraform plan
terraform apply
```

## Provider Configuration

- **Terraform:** `>= 1.15.6`
- **AWS Provider:** `~> 6.50.0`
- **Random Provider:** `~> 3.9.0`
- **AWS Region:** Set via `var.aws_region` in the provider block

## Related Documentation

- [Terraform Project README](../README.md)
- [Project Root README](../../README.md)
