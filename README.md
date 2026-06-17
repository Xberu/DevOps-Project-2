# DevOps Infrastructure-as-Code Project

A comprehensive Terraform-based infrastructure project for AWS cloud deployment with modular, reusable components and best practices.

## Project Overview

This project demonstrates Infrastructure-as-Code (IaC) best practices using Terraform to provision AWS infrastructure in a modular, scalable, and repeatable manner. It includes foundational networking, S3 backend storage, and VPC setup.

## Technologies & Requirements

- **Terraform:** >= 1.15.6
- **AWS Provider:** ~> 6.50.0
- **Random Provider:** ~> 3.9.0
- **Cloud Platform:** AWS
- **Primary Region:** us-east-1

## Project Structure

```
Terraform_project/
├── remote-backend-s3bucket/
│   └── terraform-manifests/
│       ├── s1-versions.tf
│       ├── s2-s3bucket.tf
│       ├── s2-variables.tf
│       └── s4-outputs.tf
├── terraform_foundation/
│   └── terraform-manifests/
│       ├── s1-versions.tf
│       ├── s2-s3bucket.tf
│       ├── s3-outputs.tf
│       ├── s3planv1
│       ├── terraform.tfstate
│       └── terraform.tfstate.backup
└── VPC/
    └── terraform-manifests/
        ├── s1-versions.tf
        ├── s2-variables.tf
        ├── s3-datasources-and-locals.tf
        ├── s4-vpc.tf
        ├── s5_outputs.tf
        ├── terraform.tfstate
        └── terraform.tfstate.backup
```

## Modules

### 1. Remote Backend S3 Bucket
**Location:** `remote-backend-s3bucket/terraform-manifests/`

Sets up a remote S3 bucket for storing Terraform state files with versioning enabled.

**Key Resources:**
- `aws_s3_bucket` - S3 bucket with random suffix for uniqueness
- `aws_s3_bucket_versioning` - Versioning configuration for state protection

**Variables:**
- `environment_name` - Environment identifier (default: "us-east-1")
- `aws_region` - AWS region for deployment (default: "us-east-1")

**Features:**
- Versioning enabled for state file protection
- Prevent destroy lifecycle protection (set to false for flexibility)
- Unique naming with random string suffix
- Environment and project tagging

### 2. Terraform Foundation
**Location:** `terraform_foundation/terraform-manifests/`

Base infrastructure setup and state management foundation.

**Configuration:**
- Terraform version >= 1.15.6
- AWS provider ~> 6.50.0
- Random provider ~> 3.9.0

### 3. VPC (Virtual Private Cloud)
**Location:** `VPC/terraform-manifests/`

Complete VPC setup with public/private subnets, NAT gateway, and routing configuration.

**Variables:**
```hcl
aws_region       = "us-east-1"      # AWS region
environment_name = "dev"             # Environment name
vpc_cidr         = "172.20.0.0/16"   # VPC CIDR block
subnet_newbits   = 8                 # Subnetting bits
tags = {
  Terraform = "true"                 # Global tags
}
```

**Key Resources:**
- **VPC** - Main VPC with DNS support and hostnames enabled
- **Internet Gateway** - IGW for public subnet internet access
- **Public Subnets** - Multi-AZ public subnets with auto-assigned public IPs
- **Private Subnets** - Multi-AZ private subnets
- **NAT Gateway** - Enables outbound internet access for private subnets
- **Elastic IP** - For NAT gateway allocation
- **Route Tables** - Separate public and private routing tables
- **Route Associations** - Associations between subnets and route tables

**Network Design:**
- Public subnets route through Internet Gateway (0.0.0.0/0 → IGW)
- Private subnets route through NAT Gateway (0.0.0.0/0 → NAT)
- Multi-AZ deployment for high availability
- Automatic naming convention with environment prefix

## Key Features

✅ **Modular Design** - Separate modules for backend, foundation, and VPC
✅ **State Management** - Remote S3 backend with versioning
✅ **Multi-AZ Deployment** - High availability across availability zones
✅ **Tagging Strategy** - Consistent resource tagging with environment and project info
✅ **Dynamic Subnetting** - Flexible subnet creation using locals and for_each
✅ **Security** - Private subnets with NAT for secure outbound access
✅ **Best Practices** - Terraform best practices and conventions applied

## Provider Versions

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
```

## Getting Started

1. **Initialize Terraform:**
   ```bash
   cd Terraform_project/VPC/terraform-manifests/
   terraform init
   ```

2. **Plan Deployment:**
   ```bash
   terraform plan -out=tfplan
   ```

3. **Apply Configuration:**
   ```bash
   terraform apply tfplan
   ```

4. **View Outputs:**
   ```bash
   terraform output
   ```

## Deployment Order

1. Deploy Remote Backend S3 Bucket first for state management
2. Deploy Terraform Foundation
3. Deploy VPC and networking infrastructure

## State Management

- State files are managed in each module directory
- Backup state files (.backup) are maintained
- Plan files (s3planv1) are version controlled for reference

## Tagging Convention

All resources follow a consistent tagging strategy:
- `Name` - Resource name with environment prefix
- `Environment` - Environment identifier
- `Project` - Project identifier
- `Purpose` - Resource purpose
- `Terraform` - Boolean indicating IaC management

## Future Enhancements

- [ ] EKS cluster provisioning
- [ ] RDS database setup
- [ ] Security groups and NACLs
- [ ] Lambda functions
- [ ] CloudFront distribution
- [ ] CloudWatch monitoring
- [ ] CI/CD pipeline integration
