resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "${var.environment}-${random_string.suffix.result}"
}

module "vpc" {
  source = "../vpc"

  environment        = var.environment
  cidr               = var.vpc_cidr_block
  availability_zones = var.availability_zones

  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  amazon_side_asn        = var.amazon_side_asn
  customer_gateways      = var.customer_gateways
  customer_gateway_tags  = var.customer_gateway_tags

  tags_subnet_internal = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
  tags_subnet_public = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  tags_vpc = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

module "eks" {
  source = "../eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.21"

  subnets = module.vpc.private_subnets
  vpc_id  = module.vpc.vpc_id

  admin_cidrs                                  = var.admin_cidrs
  cluster_enabled_log_types                    = var.cluster_enabled_log_types
  node_groups                                  = var.node_groups
  map_users                                    = var.map_users
  map_roles                                    = var.map_roles
  kubeconfig_aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  kubeconfig_aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
}

module "efs" {
  source = "../efs"

  aws_region     = var.aws_region
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block

  subnets = module.vpc.private_subnets
  vpc_id  = module.vpc.vpc_id

  worker_security_group_id          = module.eks.worker_security_group_id
  cluster_security_group_id         = module.eks.cluster_security_group_id
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  cluster_oidc_issuer_url           = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn                 = module.eks.oidc_provider_arn
}
