variable "name_prefix" {
  description = "Prefix used to name web tier resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC containing the web instances."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of two private subnets in different Availability Zones."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_ids) == 2 &&
      length(distinct(var.private_subnet_ids)) == 2
    )
    error_message = "Provide exactly two distinct private subnet IDs."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group for registering web instances."
  type        = string
}

variable "s3_prefix_list_id" {
  description = "Regional S3 prefix list ID for outbound package downloads."
  type        = string
}

variable "ami_id" {
  description = "ID of the Amazon Linux 2023 ARM64 image."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{17}$", var.ami_id))
    error_message = "Provide a valid AMI ID, such as ami- followed by 17 hexadecimal characters."
  }
}

variable "instance_type" {
  description = "ARM-based EC2 instance type for the web servers."
  type        = string
  default     = "t4g.nano"

  validation {
    condition = contains(
      ["t4g.nano", "t4g.micro", "t4g.small"],
      var.instance_type
    )
    error_message = "Choose t4g.nano, t4g.micro, or t4g.small."
  }
}

variable "instance_count" {
  description = "Number of web instances to maintain."
  type        = number
  default     = 2

  validation {
    condition = (
      var.instance_count >= 2 &&
      var.instance_count <= 4 &&
      floor(var.instance_count) == var.instance_count
    )
    error_message = "Choose a whole number of instances between 2 and 4."
  }
}

variable "common_tags" {
  description = "Common tags for the Auto Scaling Group, instances, and disks."
  type        = map(string)
}