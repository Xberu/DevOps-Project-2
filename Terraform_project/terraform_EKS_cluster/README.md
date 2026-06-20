# EKS Cluster Infrastructure

Terraform stacks for deploying an Amazon EKS cluster with a dedicated VPC.

## Overview

This directory contains two separate Terraform root modules that work together:

1. **VPC_terraform_manifests** — Provisions the VPC used by the EKS cluster.
2. **EKS_terraform_manifests** — Provisions the EKS control plane, IAM roles, managed node group, and subnet tags. It reads VPC outputs from remote state stored in S3.

Shell scripts are provided to apply and destroy both stacks in sequence.

## Directory Structure

```
terraform_EKS_cluster/
├── EKS_terraform_manifests/
│   ├── s1_versions.tf
│   ├── s2_variables.tf
│   ├── s3_remote-state.tf
│   ├── s4_datasources_and_locals.tf
│   ├── s5_EKS_tags.tf
│   ├── s6_eks_cluster_iamrole.tf
│   ├── s7_eks_cluster.tf
│   ├── s8_eks_nodegroup_iamrole.tf
│   ├── s9_eks_nodegroup_private.tf
│   ├── s10_eks_outputs.tf
│   ├── terraform.tfvars
│   ├── env/
│   │   ├── dev.tfvars
│   │   ├── staging.tfvars
│   │   └── prod.tfvars
│   ├── create-eks_cluster.sh
│   └── destroy.sh
└── VPC_terraform_manifests/
    ├── s1-versions.tf
    ├── s2-variables.tf
    ├── s3-vpc.tf
    ├── s4-outputs.tf
    ├── terraform.tfvars
    └── modules/vpc/
```

## Deployment Flow

```
1. VPC_terraform_manifests  ──►  S3 remote state (VPC outputs)
                                        │
2. EKS_terraform_manifests  ◄──  terraform_remote_state (reads VPC outputs)
```

### Automated Deployment

From `EKS_terraform_manifests/`:

```bash
./create-eks_cluster.sh
```

This script applies `VPC_terraform_manifests` first, then `EKS_terraform_manifests`.

### Automated Teardown

```bash
./destroy.sh
```

This script destroys the EKS stack first, then the VPC stack, and removes local `.terraform` cache directories.

### Manual Deployment

```bash
# Step 1: VPC
cd VPC_terraform_manifests
terraform init
terraform apply

# Step 2: EKS
cd ../EKS_terraform_manifests
terraform init
terraform apply
```

## Remote State Dependency

The EKS stack reads VPC outputs via `data.terraform_remote_state.vpc` in `s3_remote-state.tf`. The remote state backend configuration must match the S3 bucket and key where the VPC stack state is stored.

Default remote state settings in the EKS stack:

| Setting | Value |
|---------|-------|
| Backend | `s3` |
| Bucket | `tfstate-dev-us-east-1-8wwu3c` |
| Key | `lockfile/dev/terraform.tfstate` |
| Region | Value of `var.aws_region` |

Update the bucket name and key to match the deployed remote backend and VPC state location.

## EKS Resources Summary

| Component | Description |
|-----------|-------------|
| EKS Cluster | Control plane with configurable Kubernetes version and endpoint access |
| Cluster IAM Role | Assumed by `eks.amazonaws.com` with `AmazonEKSClusterPolicy` and `AmazonEKSVPCResourceController` |
| Node Group IAM Role | Assumed by `ec2.amazonaws.com` with worker, CNI, and ECR read-only policies |
| Managed Node Group | EC2 workers in private subnets with AL2023 AMI |
| Subnet Tags | Kubernetes ELB and cluster-shared tags on public and private subnets |

## Environment Variable Files

Environment-specific overrides are available in `EKS_terraform_manifests/env/`:

| File | Environment | Notable Settings |
|------|-------------|------------------|
| `dev.tfvars` | dev | Public endpoint, `t3.micro` nodes, ON_DEMAND |
| `staging.tfvars` | staging | Private endpoint, SPOT nodes, `t3.small` |
| `prod.tfvars` | prod | Private endpoint, ON_DEMAND, `m5.medium` nodes |

Apply with:

```bash
terraform apply -var-file="env/dev.tfvars"
```

## Prerequisites

- Remote backend S3 bucket deployed (if using remote state)
- VPC stack applied and state accessible from the EKS stack
- AWS CLI configured for `aws eks update-kubeconfig`
- Sufficient IAM permissions for EKS, EC2, and IAM resource creation

## Related Documentation

- [EKS Terraform Manifests](EKS_terraform_manifests/README.md)
- [EKS VPC Terraform Manifests](VPC_terraform_manifests/README.md)
- [Remote Backend S3 Bucket](../remote-backend-s3bucket/README.md)
- [VPC Module](../vpc_module/README.md)
- [Terraform Project README](../README.md)
