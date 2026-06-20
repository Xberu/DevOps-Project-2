# VPC Child Module (EKS)

Reusable Terraform module for VPC networking, used by the EKS VPC stack.

## Overview

This module is a copy of the VPC child module from `vpc_module/terraform-manifests/modules/vpc/`. It provisions a multi-AZ VPC with public and private subnets, an Internet Gateway, a NAT Gateway, and route tables. The EKS cluster stack consumes this module's outputs through Terraform remote state.

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
| `aws_subnet.public` | Public subnets (one per AZ, up to 3) |
| `aws_subnet.private` | Private subnets (one per AZ, up to 3) |
| `aws_eip.nat` | Elastic IP for NAT Gateway |
| `aws_nat_gateway.nat` | NAT Gateway in the first public subnet |
| `aws_route_table.public_rt` | Public route table |
| `aws_route_table.private_rt` | Private route table |
| `aws_route_table_association.public_rt_assoc` | Public subnet route associations |
| `aws_route_table_association.private_rt_assoc` | Private subnet route associations |

## Subnet Calculation

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

## EKS Integration

The EKS stack reads these outputs from remote state and uses:

- **Private subnet IDs** — EKS control plane ENIs and managed node group placement
- **Public subnet IDs** — Subnet tagging for external load balancers
- **Both subnet types** — Kubernetes cluster and ELB role tags applied in `s5_EKS_tags.tf`

## Notes

- The availability zone data source uses a hardcoded region of `us-east-1`.
- The NAT Gateway is placed in the first public subnet.
- Resource naming follows the `{environment_name}-*` pattern (e.g., `dev-vpc`, `dev-public-us-east-1a`).

## Related Documentation

- [EKS VPC Root Module](../README.md)
- [VPC Module (standalone)](../../../vpc_module/terraform-manifests/modules/vpc/README.md)
- [EKS Terraform Manifests](../../EKS_terraform_manifests/README.md)
