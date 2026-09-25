data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

module "network" {
  source = "./modules/network"

  name_prefix = "${var.project_name}-${var.environment}"
  aws_region  = var.aws_region

  availability_zones = slice(
    sort(data.aws_availability_zones.available.names),
    0,
    2
  )
}