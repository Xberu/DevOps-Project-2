# Standalone VPC

Terraform stack that provisions a Virtual Private Cloud with public and private subnets, NAT gateway, and route tables.

## Overview

This stack defines VPC networking resources directly in the root module (without a child module). It creates a multi-AZ VPC spanning up to three availability zones, with public subnets routed through an Internet Gateway and private subnets routed through a NAT Gateway.

## Directory Structure

```
VPC/
└── terraform-manifests/
    ├── s1-versions.tf              # Terraform and provider configuration
    ├── s2-variables.tf             # Input variables
    ├── s3-datasources-and-locals.tf # AZ lookup and subnet CIDR calculations
    ├── s4-vpc.tf                   # VPC, subnets, gateways, and routing
    └── s5_outputs.tf               # Output values
```

## Architecture

```
┌─────────────────────────────────────────┐
│            VPC (172.20.0.0/16)           │
├─────────────────────────────────────────┤
│  Public Subnets (per AZ)                 │
│       │                                  │
│       ▼                                  │
│  Internet Gateway                        │
│                                          │
│  Private Subnets (per AZ)                │
│       │                                  │
│       ▼                                  │
│  NAT Gateway (in first public subnet)    │
└─────────────────────────────────────────┘
```

## Resources

| Resource | Description |
|----------|-------------|
| `aws_vpc.main` | VPC with DNS support and hostnames enabled |
| `aws_internet_gateway.igw` | Internet Gateway attached to the VPC |
| `aws_subnet.public` | Public subnets (one per AZ, `map_public_ip_on_launch = true`) |
| `aws_subnet.private` | Private subnets (one per AZ) |
| `aws_eip.nat` | Elastic IP for the NAT Gateway |
| `aws_nat_gateway.nat` | NAT Gateway in the first public subnet |
| `aws_route_table.public_rt` | Routes `0.0.0.0/0` to the Internet Gateway |
| `aws_route_table.private_rt` | Routes `0.0.0.0/0` to the NAT Gateway |
| `aws_route_table_association.public_rt_assoc` | Associates public subnets with the public route table |
| `aws_route_table_association.private_rt_assoc` | Associates private subnets with the private route table |

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region |
| `environment_name` | string | `dev` | Environment identifier used in resource names |
| `vpc_cidr` | string | `172.20.0.0/16` | VPC CIDR block |
| `subnet_newbits` | number | `8` | Additional bits for subnet CIDR calculation |
| `tags` | map(string) | `{ Terraform = "true" }` | Tags merged into all resources |

## Subnet Calculation

Availability zones are retrieved via `data.aws_availability_zones.available`, limited to the first three zones.

Subnet CIDR blocks are computed with `cidrsubnet`:

- **Public subnets:** index `k` (0, 1, 2, ...)
- **Private subnets:** index `k + 10` (10, 11, 12, ...)

With `vpc_cidr = 172.20.0.0/16` and `subnet_newbits = 8`, subnets are `/24` blocks:

| Subnet | Example CIDR |
|--------|--------------|
| Public AZ 1 | `172.20.0.0/24` |
| Public AZ 2 | `172.20.1.0/24` |
| Public AZ 3 | `172.20.2.0/24` |
| Private AZ 1 | `172.20.10.0/24` |
| Private AZ 2 | `172.20.11.0/24` |
| Private AZ 3 | `172.20.12.0/24` |

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC identifier |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_id` | NAT Gateway identifier |
| `public_route_table_id` | Public route table identifier |
| `private_route_table_id` | Private route table identifier |
| `availability_zones` | List of AZs used |
| `public_subnet_map` | Map of AZ to public subnet ID |
| `private_subnet_map` | Map of AZ to private subnet ID |
| `nat_gateway_public_ip` | Public IP of the NAT Gateway Elastic IP |

## Usage

```bash
cd Terraform_project/VPC/terraform-manifests

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

### Variable Overrides

```bash
terraform plan -var="vpc_cidr=10.0.0.0/16"
terraform apply -var="environment_name=prod"
```

## Provider Configuration

- **Terraform:** `>= 1.15.6`
- **AWS Provider:** `~> 6.50.0`
- **AWS Region:** Hardcoded to `us-east-1` in the provider block (independent of `var.aws_region` used in data sources)

## State Storage

Local state by default. A commented S3 backend block is not present in this stack.

## Related Documentation

- [VPC Module (modular approach)](../vpc_module/README.md)
- [EKS VPC Stack](../terraform_EKS_cluster/VPC_terraform_manifests/README.md)
- [Terraform Project README](../README.md)
