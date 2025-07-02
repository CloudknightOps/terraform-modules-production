

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Uncomment and configure for remote state management
  # backend "s3" {
  #   bucket  = "your-terraform-state-bucket"
  #   key     = "infrastructure/terraform.tfstate"
  #   region  = "us-west-2"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}