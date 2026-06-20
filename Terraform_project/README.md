# Terraform Project

Collection of Terraform stacks for AWS infrastructure provisioning. Each subdirectory is an independent Terraform root module with its own state, variables, and outputs.

## Stacks

| Stack | Directory | Purpose |
|-------|-----------|---------|
| Remote Backend | `remote-backend-s3bucket/` | S3 bucket for centralized Terraform state |
| Foundation | `terraform_foundation/` | Provider configuration and sample S3 bucket |
| Standalone VPC | `VPC/` | VPC resources defined inline (no child module) |
| VPC Module | `vpc_module/` | VPC provisioned through a reusable child module |
| EKS Cluster | `terraform_EKS_cluster/` | VPC and EKS cluster for Kubernetes workloads |

## Provider Requirements

All stacks share the same provider constraints:

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

## Directory Layout

```
Terraform_project/
├── .gitignore
├── remote-backend-s3bucket/
│   └── terraform-manifests/
├── terraform_foundation/
│   └── terraform-manifests/
├── VPC/
│   └── terraform-manifests/
├── vpc_module/
│   └── terraform-manifests/
│       └── modules/vpc/
└── terraform_EKS_cluster/
    ├── EKS_terraform_manifests/
    │   └── env/
    └── VPC_terraform_manifests/
        └── modules/vpc/
```

## Working Directory Convention

Terraform commands are run from each stack's manifest directory:

| Stack | Working Directory |
|-------|-------------------|
| Remote Backend | `remote-backend-s3bucket/terraform-manifests/` |
| Foundation | `terraform_foundation/terraform-manifests/` |
| Standalone VPC | `VPC/terraform-manifests/` |
| VPC Module | `vpc_module/terraform-manifests/` |
| EKS VPC | `terraform_EKS_cluster/VPC_terraform_manifests/` |
| EKS Cluster | `terraform_EKS_cluster/EKS_terraform_manifests/` |

## State Backend

The `remote-backend-s3bucket` stack creates an S3 bucket and configures a remote backend with:

- Server-side encryption
- S3 lock file support (`use_lockfile = true`)
- State key path: `lockfile/{environment}/terraform.tfstate`

Other stacks contain commented backend blocks that reference the same bucket pattern. Enable those blocks after the backend bucket is created and update the bucket name to match the deployed resource.

## Deployment Relationships

```
remote-backend-s3bucket
        │
        ├──► VPC / vpc_module (optional, standalone networking)
        │
        └──► terraform_EKS_cluster
                 ├── VPC_terraform_manifests (VPC for EKS)
                 └── EKS_terraform_manifests (reads VPC state via remote state)
```

The EKS cluster stack depends on VPC outputs retrieved through `terraform_remote_state` from the S3 backend.

## Ignored Files

The project `.gitignore` excludes:

- `.terraform/` directories
- `*.tfstate` and `*.tfstate.*` files
- Plan files (`*.tfplan`, `s3plan*`)
- `.terraform.lock.hcl`
- `.env` files

## Related Documentation

- [Project Root README](../README.md)
- [Remote Backend S3 Bucket](remote-backend-s3bucket/README.md)
- [Terraform Foundation](terraform_foundation/README.md)
- [Standalone VPC](VPC/README.md)
- [VPC Module](vpc_module/README.md)
- [EKS Cluster](terraform_EKS_cluster/README.md)
