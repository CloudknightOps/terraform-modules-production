
# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.networking.availability_zones
}

# Public Subnets
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "public_subnets_by_az" {
  description = "Map of availability zones to public subnet IDs"
  value       = module.networking.public_subnets_by_az
}

# Private Subnets
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "private_subnets_by_az" {
  description = "Map of availability zones to private subnet IDs"
  value       = module.networking.private_subnets_by_az
}

# NAT Gateway Information
output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = module.networking.nat_gateway_public_ips
}

# Route Tables
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.networking.public_route_table_id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.networking.private_route_table_ids
}

