# EKS Terraform Manifests

Terraform root module for provisioning an Amazon EKS cluster, IAM roles, managed node group, and Kubernetes-required subnet tags.

## Overview

This stack creates an EKS control plane and a managed node group in private subnets. VPC networking details are retrieved from remote state via `terraform_remote_state`, decoupling the EKS deployment from direct VPC resource definitions.

## Directory Structure

```
EKS_terraform_manifests/
├── s1_versions.tf                  # Terraform, provider, and backend config
├── s2_variables.tf                 # Input variables
├── s3_remote-state.tf              # Remote state data source and VPC output passthrough
├── s4_datasources_and_locals.tf    # Local naming conventions
├── s5_EKS_tags.tf                  # Kubernetes subnet tags
├── s6_eks_cluster_iamrole.tf       # Cluster IAM role and policy attachments
├── s7_eks_cluster.tf               # EKS cluster resource
├── s8_eks_nodegroup_iamrole.tf     # Node group IAM role and policy attachments
├── s9_eks_nodegroup_private.tf     # Managed node group in private subnets
├── s10_eks_outputs.tf              # Cluster and node group outputs
├── terraform.tfvars                # Default variable values
├── env/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── create-eks_cluster.sh           # Applies VPC then EKS stacks
└── destroy.sh                      # Destroys EKS then VPC stacks
```

## Naming Convention

Local values in `s4_datasources_and_locals.tf` define resource naming:

| Local | Pattern | Example |
|-------|---------|---------|
| `local.name` | `{business_division}-{environment_name}` | `retail_store-dev` |
| `local.eks_cluster_name` | `{local.name}-{cluster_name}` | `retail_store-dev-eksdemo1` |

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region |
| `environment_name` | string | `dev` | Environment identifier |
| `business_division` | string | `retail_store` | Business division prefix for naming |
| `cluster_name` | string | `eksdemo` | EKS cluster name suffix |
| `cluster_version` | string | `null` | Kubernetes version for the control plane |
| `cluster_service_ipv4_cidr` | string | `null` | Service CIDR (optional) |
| `cluster_endpoint_private_access` | bool | `false` | Enable private API endpoint |
| `cluster_endpoint_public_access` | bool | `true` | Enable public API endpoint |
| `cluster_endpoint_public_access_cidrs` | list(string) | `["0.0.0.0/0"]` | CIDRs allowed to reach public endpoint |
| `tags` | map(string) | `{ Terraform = "true" }` | Resource tags |
| `node_instance_types` | list(string) | `["t3.small"]` | EC2 instance types for nodes |
| `node_capacity_type` | string | `ON_DEMAND` | `ON_DEMAND` or `SPOT` |
| `node_disk_size` | number | `20` | Root volume size in GiB |

## Remote State

`s3_remote-state.tf` reads VPC outputs from S3:

```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "tfstate-dev-us-east-1-8wwu3c"
    key    = "lockfile/dev/terraform.tfstate"
    region = var.aws_region
  }
}
```

VPC outputs are re-exported from this file and consumed by EKS resources and subnet tagging.

## Resources

### IAM — Cluster (`s6_eks_cluster_iamrole.tf`)

| Resource | Description |
|----------|-------------|
| `aws_iam_role.eks_cluster_role` | IAM role for the EKS control plane |
| `aws_iam_role_policy_attachment.eks-cluster-policy` | `AmazonEKSClusterPolicy` |
| `aws_iam_role_policy_attachment.eks-vpc-resource-controller-policy` | `AmazonEKSVPCResourceController` |

### EKS Cluster (`s7_eks_cluster.tf`)

| Setting | Value |
|---------|-------|
| Subnets | Private subnet IDs from remote state |
| Logging | `api`, `audit`, `authenticator`, `controllerManager`, `scheduler` |
| Authentication | `API_AND_CONFIG_MAP` with bootstrap cluster creator admin permissions |

### IAM — Node Group (`s8_eks_nodegroup_iamrole.tf`)

| Resource | Policy |
|----------|--------|
| `aws_iam_role.eks_nodegroup_role` | Trust: `ec2.amazonaws.com` |
| Worker node policy | `AmazonEKSWorkerNodePolicy` |
| CNI policy | `AmazonEKS_CNI_Policy` |
| ECR policy | `AmazonEC2ContainerRegistryReadOnly` |

### Node Group (`s9_eks_nodegroup_private.tf`)

| Setting | Value |
|---------|-------|
| Name | `{local.name}-private-ng` |
| Subnets | Private subnet IDs from remote state |
| AMI Type | `AL2023_x86_64_STANDARD` |
| Scaling | desired: 3, min: 1, max: 6 |
| Update config | `max_unavailable_percentage = 33` |
| Labels | `env`, `team` |

### Subnet Tags (`s5_EKS_tags.tf`)

Tags applied to subnets from remote state:

| Subnet Type | Tag Key | Value |
|-------------|---------|-------|
| Public | `kubernetes.io/role/elb` | `1` |
| Public | `kubernetes.io/cluster/{cluster_name}` | `shared` |
| Private | `kubernetes.io/role/internal-elb` | `1` |
| Private | `kubernetes.io/cluster/{cluster_name}` | `shared` |

## Outputs

| Output | Description |
|--------|-------------|
| `eks_cluster_endpoint` | EKS API server endpoint |
| `eks_cluster_id` | EKS cluster ID |
| `eks_cluster_version` | Kubernetes version |
| `eks_cluster_name` | Cluster name |
| `eks_cluster_certificate_authority_data` | Base64-encoded CA certificate |
| `private_node_group_name` | Managed node group name |
| `eks_node_instance_role_arn` | Node group IAM role ARN |
| `to_configure_kubectl` | `aws eks update-kubeconfig` command |

## Default Configuration (`terraform.tfvars`)

```hcl
aws_region       = "us-east-1"
environment_name = "dev"
business_division = "retail_store"
cluster_name     = "eksdemo1"
cluster_version  = "1.36"
node_instance_types = ["t3.small"]
node_capacity_type  = "ON_DEMAND"
node_disk_size      = 20
```

## Usage

```bash
cd Terraform_project/terraform_EKS_cluster/EKS_terraform_manifests

terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Environment-Specific Apply

```bash
terraform apply -var-file="env/staging.tfvars"
```

### Configure kubectl

After apply, use the output command:

```bash
aws eks --region us-east-1 update-kubeconfig --name <cluster-name>
```

Or reference the `to_configure_kubectl` output directly.

## Shell Scripts

| Script | Action |
|--------|--------|
| `create-eks_cluster.sh` | Applies `VPC_terraform_manifests`, then this stack |
| `destroy.sh` | Destroys this stack, then `VPC_terraform_manifests` |

## Backend Configuration

`s1_versions.tf` contains a commented S3 backend block. Enable it after the remote backend bucket is available and align the bucket name with the deployed state bucket.

## Related Documentation

- [EKS Cluster Overview](../README.md)
- [EKS VPC Manifests](../VPC_terraform_manifests/README.md)
- [Remote Backend S3 Bucket](../../remote-backend-s3bucket/README.md)
