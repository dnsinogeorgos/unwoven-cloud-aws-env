terraform {
  backend "s3" {
    encrypt = true
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "aws-org" {
  backend = "s3"
  config = {
    bucket = var.aws-org_bucket
    key    = var.aws-org_key
    region = var.aws-org_region
  }
}

module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

module "dev" {
  source = "../../modules/env"

  environment        = var.environment
  vpc_cidr_block     = var.vpc_cidr_block
  admin_cidrs        = ["${module.myip.address}/32"]
  availability_zones = data.aws_availability_zones.available.names

  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  cluster_enabled_log_types = var.cluster_enabled_log_types
  node_groups               = var.node_groups
  map_roles = [
    {
      rolearn  = data.terraform_remote_state.aws-org.outputs.accounts.dev.role_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
  kubeconfig_aws_authenticator_additional_args = ["-r", data.terraform_remote_state.aws-org.outputs.accounts.dev.role_arn]
  kubeconfig_aws_authenticator_env_variables   = { AWS_PROFILE = var.aws_profile }

  aws_region = data.aws_region.current.name

  tags = {
    Terraform   = "true"
    Module      = "unwoven-cloud-aws-env"
    Environment = var.environment
  }
}
