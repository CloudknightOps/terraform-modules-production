

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_default_security_group_id" {
  description = "Default security group ID of the VPC"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_main_route_table_id" {
  description = "Main route table ID of the VPC"
  value       = aws_vpc.main.main_route_table_id
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway"
  value       = aws_internet_gateway.main.arn
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_arns" {
  description = "List of public subnet ARNs"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "public_subnet_cidr_blocks" {
  description = "List of public subnet CIDR blocks"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "public_subnet_availability_zones" {
  description = "List of public subnet availability zones"
  value       = [for subnet in aws_subnet.public : subnet.availability_zone]
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_arns" {
  description = "List of private subnet ARNs"
  value       = [for subnet in aws_subnet.private : subnet.arn]
}

output "private_subnet_cidr_blocks" {
  description = "List of private subnet CIDR blocks"
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
}

output "private_subnet_availability_zones" {
  description = "List of private subnet availability zones"
  value       = [for subnet in aws_subnet.private : subnet.availability_zone]
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.enable_nat_gateway ? [for nat in aws_nat_gateway.main : nat.id] : []
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = var.enable_nat_gateway ? [for eip in aws_eip.nat : eip.public_ip] : []
}

output "elastic_ip_ids" {
  description = "List of Elastic IP IDs for NAT Gateways"
  value       = var.enable_nat_gateway ? [for eip in aws_eip.nat : eip.id] : []
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = [for rt in aws_route_table.private : rt.id]
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}

# Subnet mappings for easy reference
output "public_subnets_by_az" {
  description = "Map of availability zones to public subnet IDs"
  value = {
    for k, subnet in aws_subnet.public : subnet.availability_zone => subnet.id
  }
}

output "private_subnets_by_az" {
  description = "Map of availability zones to private subnet IDs"
  value = {
    for k, subnet in aws_subnet.private : subnet.availability_zone => subnet.id
  }
}

# Useful for other modules
output "database_subnet_group_name" {
  description = "Name that can be used for RDS subnet group (private subnets)"
  value       = "${var.name}-db-subnet-group"
}

output "elasticache_subnet_group_name" {
  description = "Name that can be used for ElastiCache subnet group (private subnets)"
  value       = "${var.name}-cache-subnet-group"
}