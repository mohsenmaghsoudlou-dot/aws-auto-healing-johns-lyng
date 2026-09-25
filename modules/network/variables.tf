variable "name_prefix" {
  description = "Prefix used to name network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 address range for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Two distinct Availability Zones for the network."
  type        = list(string)

  validation {
    condition = (
      length(var.availability_zones) == 2 &&
      length(distinct(var.availability_zones)) == 2
    )
    error_message = "Provide exactly two distinct Availability Zones."
  }
}

variable "aws_region" {
  description = "AWS region used to select the regional S3 endpoint."
  type        = string
}