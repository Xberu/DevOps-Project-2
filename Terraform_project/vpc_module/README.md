# VPC Module

Terraform root module that provisions a VPC by invoking a reusable child module at `./modules/vpc`.

## Overview

This stack separates VPC logic into a child module while the root module handles provider configuration, variables, module invocation, and output re-export. The child module creates the same networking topology as the standalone VPC stack: multi-AZ public and private subnets, Internet Gateway, NAT Gateway, and route tables.

## Directory Structure

```
vpc_module/
└── terraform-manifests/
    ├── s1-versions.tf          # Terraform, provider, and optional backend
    ├── s2-variables.tf         # Root module variables
    ├── s3-vpc.tf               # Module invocation
    ├── s4-outputs.tf           # Re-exported module outputs
    ├── terraform.tfvars        # Example variable values (commented)
    └── modules/
        └── vpc/                # Reusable VPC child module
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

## Root Module Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for the provider |
| `environment_name` | string | `dev` | Environment identifier |
| `vpc_cidr` | string | `172.20.0.0/16` | VPC CIDR block |
| `subnet_newbits` | number | `8` | Additional bits for subnet calculation |
| `tags` | map(string) | `{ Terraform = "true" }` | Tags applied to all resources |

## Root Module Outputs

All outputs are forwarded from the child module:

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

## Backend Configuration

`s1-versions.tf` contains a commented S3 backend block. When enabled, state is stored remotely in the configured S3 bucket with encryption and lock file support.

## Usage

```bash
cd Terraform_project/vpc_module/terraform-manifests

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Using a Variable File

Uncomment and customize values in `terraform.tfvars`, then apply:

```bash
terraform apply -var-file="terraform.tfvars"
```

## Consuming the Module Externally

The child module can be referenced from other Terraform configurations:

```hcl
module "vpc" {
  source = "../vpc_module/terraform-manifests/modules/vpc"

  environment_name = "prod"
  vpc_cidr         = "10.0.0.0/16"
  subnet_newbits   = 8
  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
```

## Related Documentation

- [VPC Child Module](terraform-manifests/modules/vpc/README.md)
- [Standalone VPC](../VPC/README.md)
- [EKS VPC Stack](../terraform_EKS_cluster/VPC_terraform_manifests/README.md)
- [Terraform Project README](../README.md)
