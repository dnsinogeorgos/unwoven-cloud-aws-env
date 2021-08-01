terraform {
  backend "s3" {
    encrypt = true
  }
}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "aws-org" {
  backend = "s3"
  config = {
    bucket = var.aws-org_bucket
    key    = var.aws-org_key
    region = var.aws-org_region
  }
}

locals {
  state      = data.terraform_remote_state.aws-org.outputs.accounts["int"]
  cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 5, 0)
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.26.1"

  cidr_block = local.state["cidr_block"]

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.39.3"

  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  cidr_block         = local.cidr_block
  availability_zones = data.aws_availability_zones.available.names

  nat_gateway_enabled  = false
  nat_instance_enabled = true
  nat_instance_type    = "t3.nano"

  context = module.this.context
}

module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.31.0"

  name = "efs"

  region  = var.aws_region
  vpc_id  = module.vpc.vpc_id
  subnets = module.subnets.private_subnet_ids

  encrypted              = true
  security_group_enabled = true
  security_group_rules = [
    {
      "type" : "ingress"
      "from_port" : 0,
      "to_port" : 0,
      "protocol" : -1,
      "cidr_blocks" : concat(
        module.subnets.private_subnet_cidrs,
        module.subnets.public_subnet_cidrs
      ),
    },
  ]

  context = module.this.context
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.42.1"

  region     = var.aws_region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  cluster_encryption_config_enabled = true
  cluster_log_retention_period      = 0
  enabled_cluster_log_types         = []

  kubernetes_version      = "1.21"
  oidc_provider_enabled   = true
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  map_additional_iam_roles = [
    {
      rolearn  = local.state["role_arn"],
      username = "admin",
      groups = [
      "system:masters"]
    }
  ]

  context = module.this.context
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.24.0"

  instance_types = ["t3.small"]
  subnet_ids     = module.subnets.private_subnet_ids
  desired_size   = "3"
  min_size       = "1"
  max_size       = "6"
  cluster_name   = module.eks_cluster.eks_cluster_id

  cluster_autoscaler_enabled = "true"

  context = module.this.context

  module_depends_on = module.eks_cluster.kubernetes_config_map_id
}
