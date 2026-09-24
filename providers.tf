terraform {
  required_version = ">= 1.16.2, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Project     = "autoheal"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}