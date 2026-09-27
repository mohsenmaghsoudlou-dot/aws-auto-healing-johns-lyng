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

module "load_balancer" {
  source = "./modules/load-balancer"

  name_prefix       = "${var.project_name}-${var.environment}"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  depends_on = [module.network]
}

module "web_tier" {
  source = "./modules/web-tier"

  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  s3_prefix_list_id  = module.network.s3_prefix_list_id

  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arn

  ami_id = var.ami_id

  # This account's free plan rejected t4g.nano; use eligible ARM64 capacity for testing.
  instance_type = "t4g.micro"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    module.network,
    module.load_balancer
  ]
}
