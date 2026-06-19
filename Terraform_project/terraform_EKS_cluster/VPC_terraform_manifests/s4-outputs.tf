output "vpc_id" {
  value = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
  description = "IDs of the public subnets"
}   

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
  description = "IDs of the private subnets"
}   

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
  description = "ID of the NAT Gateway"
}   

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
  description = "ID of the public route table"
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
  description = "ID of the private route table"
}

output "availability_zones" {
  value = module.vpc.availability_zones
  description = "List of availability zones used for subnets"
}   

output "public_subnet_map" {
  value = module.vpc.public_subnet_map
  description = "Map of public subnet IDs by availability zone"
}

output "private_subnet_map" {
  value = module.vpc.private_subnet_map
  description = "Map of private subnet IDs by availability zone"
}

output "nat_gateway_public_ip" {
  value = module.vpc.nat_gateway_public_ip
  description = "Public IP address of the NAT Gateway"
}