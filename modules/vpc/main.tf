locals {
  cidr            = var.cidr
  private_subnets = [for i in [0, 1, 2] : cidrsubnet(var.cidr, 8, i)]
  public_subnets  = [for i in [100, 101, 102] : cidrsubnet(var.cidr, 8, i)]
  intra_subnets   = [for i in [200, 201, 202] : cidrsubnet(var.cidr, 8, i)]
}

// https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = var.environment

  azs                    = var.availability_zones
  cidr                   = local.cidr
  create_egress_only_igw = true
  create_igw             = true
  create_vpc             = true
  enable_dns_hostnames   = true
  enable_dns_support     = true

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_vpn_gateway    = true
  amazon_side_asn       = var.amazon_side_asn
  vpn_gateway_az        = var.availability_zones[0]
  customer_gateways     = var.customer_gateways
  customer_gateway_tags = var.customer_gateway_tags

  intra_subnets       = local.intra_subnets
  private_subnets     = local.private_subnets
  public_subnets      = local.public_subnets
  intra_subnet_tags   = var.tags_subnet_internal
  private_subnet_tags = var.tags_subnet_internal
  public_subnet_tags  = var.tags_subnet_public

  tags = var.tags_vpc
}
