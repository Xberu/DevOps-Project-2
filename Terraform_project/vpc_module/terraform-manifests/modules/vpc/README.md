# VPC Child Module

Reusable Terraform module for provisioning AWS VPC networking resources.

## Overview

This module creates a VPC with public and private subnets across up to three availability zones, an Internet Gateway, a NAT Gateway, and associated route tables. It is invoked by the root module in `vpc_module/terraform-manifests/` and is also copied under `terraform_EKS_cluster/VPC_terraform_manifests/modules/vpc/`.

## Files

| File | Purpose |
|------|---------|
| `variables.tf` | Module input variables |
| `datasources-and-locals.tf` | Availability zone lookup and subnet CIDR calculations |
| `main.tf` | VPC, subnet, gateway, and routing resources |
| `outputs.tf` | Module output values |

## Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment_name` | string | `dev` | Prefix for resource names |
| `vpc_cidr` | string | `172.20.0.0/16` | VPC CIDR block |
| `subnet_newbits` | number | `8` | Additional bits for subnet CIDR calculation |
| `tags` | map(string) | `{ Terraform = "true" }` | Tags merged into all resources |

## Resources

| Resource | Description |
|----------|-------------|
| `aws_vpc.main` | VPC with DNS support and hostnames |
| `aws_internet_gateway.igw` | Internet Gateway |
| `aws_subnet.public` | Public subnets (one per AZ) |
| `aws_subnet.private` | Private subnets (one per AZ) |
| `aws_eip.nat` | Elastic IP for NAT Gateway |
| `aws_nat_gateway.nat` | NAT Gateway in the first public subnet |
| `aws_route_table.public_rt` | Public route table (`0.0.0.0/0` → IGW) |
| `aws_route_table.private_rt` | Private route table (`0.0.0.0/0` → NAT) |
| `aws_route_table_association.public_rt_assoc` | Public subnet associations |
| `aws_route_table_association.private_rt_assoc` | Private subnet associations |

## Subnet Calculation

The module queries available AZs and uses the first three:

```hcl
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnet = [
    for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)
  ]

  private_subnet = [
    for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)
  ]
}
```

Public subnets use index `k`; private subnets use index `k + 10` to avoid CIDR overlap.

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC identifier |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_id` | NAT Gateway identifier |
| `public_route_table_id` | Public route table identifier |
| `private_route_table_id` | Private route table identifier |
| `availability_zones` | AZs used |
| `public_subnet_map` | AZ-to-public-subnet ID map |
| `private_subnet_map` | AZ-to-private-subnet ID map |
| `nat_gateway_public_ip` | NAT Gateway public IP |

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  environment_name = "dev"
  vpc_cidr         = "172.20.0.0/16"
  subnet_newbits   = 8
  tags = {
    Terraform = "true"
  }
}
```

## Notes

- The availability zone data source in this module uses a hardcoded region of `us-east-1` in `datasources-and-locals.tf`.
- The NAT Gateway is placed in the first public subnet returned by `values(aws_subnet.public)[0]`.
- `prevent_destroy` is set to `false` on the VPC resource.

## Related Documentation

- [VPC Module Root](../README.md)
- [Standalone VPC](../../VPC/README.md)
