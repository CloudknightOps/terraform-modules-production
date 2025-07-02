# networking/main.tf

# Get available AZs if not specified
data "aws_availability_zones" "available" {
  state = "available"
}

# Use provided AZs or default to first 2 available
locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
  
  # Ensure we have enough AZs for our subnets
  public_subnets = {
    for i, cidr in var.public_subnet_cidrs : i => {
      cidr = cidr
      az   = local.azs[i % length(local.azs)]
    }
  }
  
  private_subnets = {
    for i, cidr in var.private_subnet_cidrs : i => {
      cidr = cidr
      az   = local.azs[i % length(local.azs)]
    }
  }
  
  # Common tags merged with resource-specific tags
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
  })
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    local.common_tags,
    var.vpc_tags,
    {
      Name = "${var.name}-vpc"
      Type = "VPC"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    var.internet_gateway_tags,
    {
      Name = "${var.name}-igw"
      Type = "InternetGateway"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    local.common_tags,
    var.public_subnet_tags,
    {
      Name = "${var.name}-public-${each.key + 1}"
      Type = "PublicSubnet"
      Tier = "Public"
      AZ   = each.value.az
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    local.common_tags,
    var.private_subnet_tags,
    {
      Name = "${var.name}-private-${each.key + 1}"
      Type = "PrivateSubnet"
      Tier = "Private"
      AZ   = each.value.az
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  # Create EIPs based on NAT Gateway strategy
  for_each = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 
    { "0" = local.public_subnets["0"] } : 
    local.public_subnets
  ) : {}

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = var.single_nat_gateway ? "${var.name}-eip-nat" : "${var.name}-eip-nat-${each.key + 1}"
      Type = "ElasticIP"
      Purpose = "NATGateway"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  # Create NAT Gateways based on strategy
  for_each = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 
    { "0" = local.public_subnets["0"] } : 
    local.public_subnets
  ) : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    local.common_tags,
    var.nat_gateway_tags,
    {
      Name = var.single_nat_gateway ? "${var.name}-nat" : "${var.name}-nat-${each.key + 1}"
      Type = "NATGateway"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-public-rt"
      Type = "RouteTable"
      Tier = "Public"
    }
  )
}

# Private Route Tables
resource "aws_route_table" "private" {
  # Create route tables based on NAT Gateway strategy
  for_each = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 
    { for k, v in local.private_subnets : k => merge(v, { nat_key = "0" }) } :
    { for k, v in local.private_subnets : k => merge(v, { nat_key = k }) }
  ) : local.private_subnets

  vpc_id = aws_vpc.main.id

  # Only add NAT route if NAT Gateway is enabled
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[each.value.nat_key].id
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-private-rt-${each.key + 1}"
      Type = "RouteTable"
      Tier = "Private"
      AZ   = each.value.az
    }
  )
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}