

# Local values for configuration
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    CreatedBy   = "Terraform"
    Owner       = var.owner
  }
}

# Call the networking module
module "networking" {
  source = "./networking"

  # Basic configuration
  name                   = local.name_prefix
  vpc_cidr              = var.vpc_cidr
  
  # Subnet configuration
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
  
  # NAT Gateway configuration
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  
  # VPC configuration
  enable_dns_hostnames       = true
  enable_dns_support         = true
  map_public_ip_on_launch    = true
  
  # Tags
  tags = local.common_tags
  
  # Resource-specific tags (optional)
  vpc_tags = {
    Purpose = "Main application VPC"
  }
  
  public_subnet_tags = {
    Tier = "Public"
    "kubernetes.io/role/elb" = "1"  # For AWS Load Balancer Controller
  }
  
  private_subnet_tags = {
    Tier = "Private"
    "kubernetes.io/role/internal-elb" = "1"  # For AWS Load Balancer Controller
  }
}

