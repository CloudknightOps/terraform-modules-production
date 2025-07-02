

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be provided if specified."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnet CIDRs must be provided."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP addresses to instances launched in public subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}

variable "internet_gateway_tags" {
  description = "Additional tags for the Internet Gateway"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags for NAT Gateways"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name prefix for resources"
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Name must start with a letter and contain only letters, numbers, and hyphens."
  }
}