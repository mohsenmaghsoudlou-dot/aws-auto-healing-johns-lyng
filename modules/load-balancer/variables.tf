variable "name_prefix" {
  description = "Prefix used to name load balancer resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC containing the load balancer resources."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of two public subnets in different Availability Zones."
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_ids) == 2 &&
      length(distinct(var.public_subnet_ids)) == 2
    )
    error_message = "Provide exactly two distinct public subnet IDs."
  }
}