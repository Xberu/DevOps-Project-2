# EKS VPC Terraform Manifests

Terraform root module that provisions the VPC used by the EKS cluster stack.

## Overview

This stack invokes the reusable VPC child module at `./modules/vpc` to create networking infrastructure for EKS. VPC outputs are stored in Terraform state and consumed by the EKS stack through `terraform_remote_state`.

## Directory Structure

```
VPC_terraform_manifests/
├── s1-versions.tf          # Terraform, provider, and optional backend
├── s2-variables.tf         # Input variables
├── s3-vpc.tf               # Module invocation
├── s4-outputs.tf           # VPC outputs for remote state consumption
├── terraform.tfvars        # Example variable values (commented)
└── modules/
    └── vpc/                # VPC child module
        ├── datasources-and-locals.tf
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Module Invocation

```hcl
module "vpc" {
  source           = "./modules/vpc"
  environment_name = var.environment_name
  vpc_cidr         = var.vpc_cidr
  subnet_newbits   = var.subnet_newbits
  tags             = var.tags
}
```

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for the provider |
| `environment_name` | string | `dev` | Environment identifier |
| `vpc_cidr` | string | `172.20.0.0/16` | VPC CIDR block |
| `subnet_newbits` | number | `8` | Additional bits for subnet calculation |
| `tags` | map(string) | `{ Terraform = "true" }` | Tags applied to all resources |

## Outputs

These outputs are read by the EKS stack via remote state:

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC identifier |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `nat_gateway_id` | NAT Gateway identifier |
| `public_route_table_id` | Public route table identifier |
| `private_route_table_id` | Private route table identifier |
| `availability_zones` | AZs used for subnets |
| `public_subnet_map` | AZ-to-public-subnet mapping |
| `private_subnet_map` | AZ-to-private-subnet mapping |
| `nat_gateway_public_ip` | NAT Gateway public IP |

## VPC Topology

The child module provisions:

- VPC with DNS support and hostnames
- Internet Gateway
- Public subnets (up to 3 AZs) with auto-assigned public IPs
- Private subnets (up to 3 AZs)
- NAT Gateway with Elastic IP in the first public subnet
- Public and private route tables with associations

Subnet CIDR blocks use index `k` for public subnets and `k + 10` for private subnets.

## Backend Configuration

`s1-versions.tf` contains a commented S3 backend block:

```hcl
# backend "s3" {
#   bucket       = "tfstate-dev-us-east-1-8wwu3c"
#   key          = "lockfile/dev/terraform.tfstate"
#   region       = "us-east-1"
#   encrypt      = true
#   use_lockfile = true
# }
```

Enable this block so the EKS stack can read VPC outputs from remote state. The bucket name and key must match the configuration in `EKS_terraform_manifests/s3_remote-state.tf`.

## Usage

This stack is applied before the EKS stack.

```bash
cd Terraform_project/terraform_EKS_cluster/VPC_terraform_manifests

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

It is also invoked automatically by `EKS_terraform_manifests/create-eks_cluster.sh`.

## Teardown

Destroy this stack after the EKS stack has been destroyed:

```bash
terraform destroy
```

Or use `EKS_terraform_manifests/destroy.sh`, which handles both stacks in order.

## Related Documentation

- [VPC Child Module](modules/vpc/README.md)
- [EKS Cluster Overview](../README.md)
- [EKS Terraform Manifests](../EKS_terraform_manifests/README.md)
- [VPC Module (standalone)](../../vpc_module/README.md)
