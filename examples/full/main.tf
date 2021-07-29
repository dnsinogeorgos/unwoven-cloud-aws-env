data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module "full" {
  source = "../../modules/env"

  environment        = var.environment
  vpc_cidr_block     = var.vpc_cidr_block
  admin_cidrs        = ["${module.myip.address}/32"]
  availability_zones = data.aws_availability_zones.available.names

  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  amazon_side_asn        = var.amazon_side_asn
  customer_gateways      = var.customer_gateways
  customer_gateway_tags  = var.customer_gateway_tags

  cluster_enabled_log_types = var.cluster_enabled_log_types
  node_groups               = var.node_groups
  map_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = "example"
      groups   = ["system:masters"]
    },
  ]

  aws_region = data.aws_region.current.name
}
