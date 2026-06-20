# AWS Infrastructure-as-Code Project

Terraform configurations for provisioning AWS infrastructure, including remote state storage, networking (VPC), reusable VPC modules, and Amazon EKS clusters.

## Overview

This repository organizes Infrastructure-as-Code (IaC) into separate Terraform stacks. Each stack targets a specific layer of the infrastructure: state backend, foundation resources, standalone VPC, modular VPC, and EKS with its supporting VPC. Stacks can be deployed independently or in sequence depending on the target environment.

## Prerequisites

| Requirement | Version / Detail |
|-------------|------------------|
| Terraform | `>= 1.15.6` |
| AWS Provider | `~> 6.50.0` |
| Random Provider | `~> 3.9.0` |
| AWS CLI | Configured with credentials for the target account |
| AWS Account | Permissions to create VPC, S3, IAM, and EKS resources |
| Default Region | `us-east-1` (configurable per stack) |

## Repository Structure

```
project-2/
├── README.md
└── Terraform_project/
    ├── README.md
    ├── .gitignore
    ├── remote-backend-s3bucket/       # S3 bucket for Terraform remote state
    ├── terraform_foundation/          # Foundation S3 bucket example
    ├── VPC/                           # Standalone VPC (inline resources)
    ├── vpc_module/                    # VPC deployed via reusable module
    └── terraform_EKS_cluster/         # EKS cluster and dedicated VPC stack
        ├── EKS_terraform_manifests/
        └── VPC_terraform_manifests/
```

## Components

| Component | Path | Description |
|-----------|------|-------------|
| Remote Backend | [Terraform_project/remote-backend-s3bucket](Terraform_project/remote-backend-s3bucket/README.md) | S3 bucket with versioning for Terraform state storage |
| Foundation | [Terraform_project/terraform_foundation](Terraform_project/terraform_foundation/README.md) | Base provider setup and sample S3 bucket |
| Standalone VPC | [Terraform_project/VPC](Terraform_project/VPC/README.md) | VPC with public/private subnets, NAT gateway, and routing |
| VPC Module | [Terraform_project/vpc_module](Terraform_project/vpc_module/README.md) | Root module that invokes a reusable VPC child module |
| EKS Cluster | [Terraform_project/terraform_EKS_cluster](Terraform_project/terraform_EKS_cluster/README.md) | EKS control plane, node groups, IAM roles, and VPC integration |

## Deployment Order

Recommended sequence when building the full stack:

1. **Remote Backend S3 Bucket** — Creates the S3 bucket used for remote state storage.
2. **Terraform Foundation** — Optional; provisions a separate sample S3 bucket for baseline testing.
3. **VPC** — Deploy either the standalone VPC stack or the VPC module stack for networking.
4. **EKS Cluster** — Deploy the EKS VPC stack first, then the EKS cluster stack (see EKS documentation).

For the EKS workflow, use the helper scripts in `terraform_EKS_cluster/EKS_terraform_manifests/` or apply each stack manually in order.

## Common Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for resource deployment |
| `environment_name` | string | `dev` | Environment identifier |
| `vpc_cidr` | string | `172.20.0.0/16` | VPC CIDR block |
| `subnet_newbits` | number | `8` | Additional bits for subnet CIDR calculation |
| `tags` | map(string) | `{ Terraform = "true" }` | Tags applied to resources |

## Terraform Commands

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
terraform destroy
```

## State Management

- State files (`*.tfstate`, `*.tfstate.*`) and plan files are excluded via `.gitignore`.
- The remote backend stack configures an S3 backend with encryption and lock file support.
- Several stacks include commented S3 backend blocks that can be enabled after the backend bucket exists.
- The EKS stack reads VPC outputs from remote state stored in S3.

## Security Notes

- IAM roles for EKS follow AWS managed policy attachments for cluster and node group operations.
- EKS control plane and worker nodes are placed in private subnets.
- Cluster endpoint access (public/private) and allowed CIDRs are configurable via variables.
- S3 state buckets use versioning; access should be restricted through IAM policies.

## Documentation Index

- [Terraform Project](Terraform_project/README.md)
- [Remote Backend S3 Bucket](Terraform_project/remote-backend-s3bucket/README.md)
- [Terraform Foundation](Terraform_project/terraform_foundation/README.md)
- [Standalone VPC](Terraform_project/VPC/README.md)
- [VPC Module](Terraform_project/vpc_module/README.md)
- [EKS Cluster](Terraform_project/terraform_EKS_cluster/README.md)
