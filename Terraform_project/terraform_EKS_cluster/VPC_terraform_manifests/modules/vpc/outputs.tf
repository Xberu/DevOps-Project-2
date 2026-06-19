output "vpc_id" {
  value = aws_vpc.main.id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
  description = "IDs of the public subnets"
}   

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
  description = "IDs of the private subnets"
}   

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
  description = "ID of the NAT Gateway"
}   

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
  description = "ID of the public route table"
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
  description = "ID of the private route table"
}

output "availability_zones" {
  value = local.azs
  description = "List of availability zones used for subnets"
}   

output "public_subnet_map" {
  value = { for subnet in aws_subnet.public : subnet.availability_zone => subnet.id }
  description = "Map of public subnet IDs by availability zone"
}

output "private_subnet_map" {
  value = { for subnet in aws_subnet.private : subnet.availability_zone => subnet.id }
  description = "Map of private subnet IDs by availability zone"
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
  description = "Public IP address of the NAT Gateway"
}