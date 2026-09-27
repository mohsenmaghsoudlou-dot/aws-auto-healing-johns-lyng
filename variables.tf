variable "ami_id" {
  description = "Amazon Linux 2023 ARM64 AMI ID in the selected AWS region."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{17}$", var.ami_id))
    error_message = "Provide an AMI ID beginning with ami- followed by 17 hexadecimal characters."
  }
}

variable "aws_region" {
  description = "AWS region in which to deploy the infrastructure."
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Short project name used in resource names and tags."
  type        = string
  default     = "autoheal"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.project_name))
    error_message = "Use 2–16 lowercase letters, numbers, or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}
