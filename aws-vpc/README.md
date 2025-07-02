# AWS Networking Terraform Module

A production-ready Terraform module for creating AWS VPC infrastructure with public and private subnets, NAT gateways, and all necessary networking components.

## Architecture

This module creates:
- **VPC** with customizable CIDR block
- **Public Subnets** in multiple availability zones with internet access
- **Private Subnets** in multiple availability zones with NAT gateway access
- **Internet Gateway** for public subnet internet access
- **NAT Gateway(s)** with Elastic IP(s) for private subnet egress
- **Route Tables** and associations for proper traffic routing

## Features

- ✅ **Multi-AZ deployment** for high availability
- ✅ **Flexible NAT Gateway strategy** (single or per-AZ for cost optimization)
- ✅ **Comprehensive tagging** support
- ✅ **Input validation** for all variables
- ✅ **Production-ready** outputs for integration with other modules
- ✅ **Cost optimization** options for development environments
- ✅ **Kubernetes-ready** with appropriate subnet tags

## Quick Start

```hcl
module "networking" {
  source = "./networking"

  name                 = "my-app-prod"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Usage Examples

### Basic Usage
```hcl
module "networking" {
  source = "./networking"
  
  name     = "my-project-dev"
  vpc_cidr = "10.0.0.0/16"
  
  tags = {
    Environment = "development"
    Owner       = "platform-team"
  }
}
```

### Production Environment with High Availability
```hcl
module "networking" {
  source = "./networking"
  
  name                   = "my-project-prod"
  vpc_cidr              = "10.0.0.0/16"
  availability_zones    = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  
  # Each AZ gets its own NAT Gateway for HA
  single_nat_gateway = false
  
  tags = {
    Environment = "production"
    Project     = "my-project"
    CostCenter  = "engineering"
  }
}
```

### Development Environment (Cost Optimized)
```hcl
module "networking" {
  source = "./networking"
  
  name                 = "my-project-dev"
  vpc_cidr            = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
  
  # Single NAT Gateway to reduce costs
  single_nat_gateway = true
  
  tags = {
    Environment = "development"
    AutoShutdown = "true"
  }
}
```

### Without NAT Gateway (Public Subnets Only)
```hcl
module "networking" {
  source = "./networking"
  
  name                = "my-project-public"
  vpc_cidr           = "10.2.0.0/16"
  public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs = ["10.2.10.0/24", "10.2.20.0/24"]
  
  # Disable NAT Gateway for cost savings
  enable_nat_gateway = false
}
```

## Directory Structure

```
.
├── networking/              # Networking module directory
│   ├── main.tf             # Core networking resources
│   ├── variables.tf        # Module input variables with validation
│   ├── outputs.tf          # Module outputs
│   └── versions.tf         # Provider version constraints
├── main.tf                 # Root module (calls networking module)
├── variables.tf            # Root module variables
├── provider.tf             # AWS provider configuration
├── outputs.tf              # Root module outputs
└── README.md               # This documentation
```

## Root Module Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `aws_region` | AWS region for resources | `string` | `"us-west-2"` | no |
| `project_name` | Name of the project | `string` | `"my-project"` | no |
| `environment` | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| `owner` | Owner of the resources | `string` | `"platform-team"` | no |
| `vpc_cidr` | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `availability_zones` | List of availability zones to use for subnets | `list(string)` | `[]` | no |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `list(string)` | `["10.0.10.0/24", "10.0.20.0/24"]` | no |
| `single_nat_gateway` | Use a single NAT Gateway for all private subnets | `bool` | `false` | no |
| `enable_nat_gateway` | Enable NAT Gateway for private subnets | `bool` | `true` | no |

## Networking Module Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name prefix for resources | `string` | `"main"` | no |
| `vpc_cidr` | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `availability_zones` | List of availability zones to use for subnets | `list(string)` | `[]` | no |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `list(string)` | `["10.0.10.0/24", "10.0.20.0/24"]` | no |
| `enable_dns_hostnames` | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| `enable_dns_support` | Enable DNS support in the VPC | `bool` | `true` | no |
| `single_nat_gateway` | Use a single NAT Gateway for all private subnets | `bool` | `false` | no |
| `enable_nat_gateway` | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| `map_public_ip_on_launch` | Auto-assign public IP addresses to instances in public subnets | `bool` | `true` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |
| `vpc_tags` | Additional tags for the VPC | `map(string)` | `{}` | no |
| `public_subnet_tags` | Additional tags for public subnets | `map(string)` | `{}` | no |
| `private_subnet_tags` | Additional tags for private subnets | `map(string)` | `{}` | no |
| `internet_gateway_tags` | Additional tags for the Internet Gateway | `map(string)` | `{}` | no |
| `nat_gateway_tags` | Additional tags for NAT Gateways | `map(string)` | `{}` | no |

## Outputs

### Root Module Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `availability_zones` | List of availability zones used |
| `public_subnet_ids` | List of public subnet IDs |
| `public_subnets_by_az` | Map of availability zones to public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `private_subnets_by_az` | Map of availability zones to private subnet IDs |
| `nat_gateway_public_ips` | List of NAT Gateway public IP addresses |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | List of private route table IDs |
| `database_subnet_group_name` | Suggested name for RDS subnet group |

### Networking Module Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_arn` | ARN of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `vpc_default_security_group_id` | Default security group ID of the VPC |
| `vpc_main_route_table_id` | Main route table ID of the VPC |
| `internet_gateway_id` | ID of the Internet Gateway |
| `internet_gateway_arn` | ARN of the Internet Gateway |
| `public_subnet_ids` | List of public subnet IDs |
| `public_subnet_arns` | List of public subnet ARNs |
| `public_subnet_cidr_blocks` | List of public subnet CIDR blocks |
| `public_subnet_availability_zones` | List of public subnet availability zones |
| `private_subnet_ids` | List of private subnet IDs |
| `private_subnet_arns` | List of private subnet ARNs |
| `private_subnet_cidr_blocks` | List of private subnet CIDR blocks |
| `private_subnet_availability_zones` | List of private subnet availability zones |
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `nat_gateway_public_ips` | List of NAT Gateway public IP addresses |
| `elastic_ip_ids` | List of Elastic IP IDs for NAT Gateways |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | List of private route table IDs |
| `public_subnets_by_az` | Map of availability zones to public subnet IDs |
| `private_subnets_by_az` | Map of availability zones to private subnet IDs |
| `database_subnet_group_name` | Name that can be used for RDS subnet group |
| `elasticache_subnet_group_name` | Name that can be used for ElastiCache subnet group |

## Deployment Options

### Option 1: Using Default Values
```bash
terraform init
terraform plan
terraform apply
```

### Option 2: Using Command Line Variables
```bash
terraform apply \
  -var="environment=prod" \
  -var="vpc_cidr=10.1.0.0/16" \
  -var="single_nat_gateway=false"
```

### Option 3: Using terraform.tfvars File
Create a `terraform.tfvars` file:
```hcl
# terraform.tfvars
aws_region           = "us-east-1"
project_name         = "my-awesome-project"
environment          = "production"
owner               = "devops-team"

# Network configuration
vpc_cidr            = "10.1.0.0/16"
availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]

# NAT Gateway configuration
enable_nat_gateway = true
single_nat_gateway = false  # High availability setup
```

Then run:
```bash
terraform apply
```

### Option 4: Using Environment-Specific tfvars Files
Create separate files for different environments:

**dev.tfvars:**
```hcl
environment = "dev"
vpc_cidr = "10.0.0.0/16"
single_nat_gateway = true  # Cost optimization for dev
```

**prod.tfvars:**
```hcl
environment = "prod"
vpc_cidr = "10.1.0.0/16"
single_nat_gateway = false  # High availability for prod
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
```

Deploy with:
```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform >= 1.0** installed
3. **AWS Provider >= 5.0**
4. **Appropriate IAM permissions** for creating VPC resources

## Required IAM Permissions

Your AWS credentials need the following permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcAttribute",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:DescribeSubnets",
        "ec2:ModifySubnetAttribute",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:DescribeInternetGateways",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:DescribeNatGateways",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:DescribeAddresses",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:DescribeRouteTables",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    }
  ]
}
```

## Cost Considerations

### NAT Gateway Costs
- **Per NAT Gateway**: ~$45/month + data processing charges
- **Single NAT Gateway**: Use `single_nat_gateway = true` for development
- **Multi-AZ NAT Gateways**: Use `single_nat_gateway = false` for production

### Example Monthly Costs (us-west-2)
- **Development** (single NAT): ~$45-60/month
- **Production** (2 NAT gateways): ~$90-120/month
- **High Availability** (3 NAT gateways): ~$135-180/month

*Note: Costs include NAT Gateway hourly charges and estimated data processing fees*

## Best Practices Implemented

✅ **Multi-AZ deployment** for high availability  
✅ **Proper subnet sizing** with room for growth  
✅ **Comprehensive tagging** strategy  
✅ **Input validation** for all variables  
✅ **Flexible NAT Gateway strategy** for cost optimization  
✅ **Kubernetes-ready** subnet tags  
✅ **Production-ready outputs** for integration  
✅ **Clean module structure** following Terraform best practices  
✅ **Comprehensive documentation**  

## Integration Examples

### Using with RDS
```hcl
resource "aws_db_subnet_group" "main" {
  name       = module.networking.database_subnet_group_name
  subnet_ids = module.networking.private_subnet_ids

  tags = {
    Name = "Main DB subnet group"
  }
}
```

### Using with Application Load Balancer
```hcl
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.networking.public_subnet_ids

  tags = {
    Environment = var.environment
  }
}
```

### Using with EKS
```hcl
resource "aws_eks_cluster" "main" {
  name     = "main-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = concat(
      module.networking.public_subnet_ids,
      module.networking.private_subnet_ids
    )
  }
}
```

## Troubleshooting

### Common Issues

1. **CIDR Overlap**: Ensure subnet CIDRs don't overlap and fit within VPC CIDR
2. **AZ Availability**: Some regions have limited AZs - let the module auto-select if unsure
3. **NAT Gateway Limits**: AWS has limits on NAT Gateways per AZ (default: 5)
4. **Elastic IP Limits**: Default limit is 5 EIPs per region

### Validation Errors
The module includes comprehensive validation. Common validation failures:

- Invalid CIDR format
- Insufficient subnet CIDRs (minimum 2 each for public/private)
- Invalid environment name (must be dev, staging, or prod)
- Invalid AWS region format

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update documentation
5. Submit a pull request

## License

This module is released under the MIT License.