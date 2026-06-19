# DataSource
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-us-east-1-8wwu3c" #change after creating s3 bucket for remote state
    key = "lockfile/dev/terraform.tfstate" #verify once
    region = var.aws_region
  }
}

# Outputs

output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  description = "IDs of the private subnets"
}

output "nat_gateway_id" {
  value = data.terraform_remote_state.vpc.outputs.nat_gateway_id
  description = "ID of the NAT Gateway"
}

output "public_route_table_id" {
  value = data.terraform_remote_state.vpc.outputs.public_route_table_id
  description = "ID of the public route table"
}

output "private_route_table_id" {
  value = data.terraform_remote_state.vpc.outputs.private_route_table_id
  description = "ID of the private route table"
}

output "availability_zones" {
  value = data.terraform_remote_state.vpc.outputs.availability_zones
  description = "List of availability zones used for subnets"
}

output "public_subnet_map" {
  value = data.terraform_remote_state.vpc.outputs.public_subnet_map
  description = "Map of public subnet IDs by availability zone"
}

output "private_subnet_map" {
  value = data.terraform_remote_state.vpc.outputs.private_subnet_map
  description = "Map of private subnet IDs by availability zone"
}

output "nat_gateway_public_ip" {
  value = data.terraform_remote_state.vpc.outputs.nat_gateway_public_ip
  description = "Public IP address of the NAT Gateway"
}