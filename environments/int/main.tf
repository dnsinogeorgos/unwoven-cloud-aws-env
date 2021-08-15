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
  account    = data.terraform_remote_state.aws-org.outputs.accounts[module.this.namespace]
  github     = data.terraform_remote_state.aws-org.outputs.github
  cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 5, 0)
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.26.1"

  cidr_block = local.account["cidr_block"]

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

  private_subnets_additional_tags = { "kubernetes.io/role/internal-elb" = 1 }
  public_subnets_additional_tags  = { "kubernetes.io/role/elb" = 1 }

  context = module.this.context
}

// This is tricky to work with, be sure to read about aws_auth
// and kubernetes_config_map_ignore_role_changes
// https://registry.terraform.io/modules/cloudposse/eks-cluster/aws/latest
// TODO: implement users, roles and accounts. inherit from aws-org?
module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.42.1"

  region     = var.aws_region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  cluster_encryption_config_enabled = true
  cluster_log_retention_period      = 7
  enabled_cluster_log_types         = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  kubernetes_version      = "1.21"
  oidc_provider_enabled   = true
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  kube_data_auth_enabled          = false
  kube_exec_auth_enabled          = true
  kube_exec_auth_role_arn_enabled = true
  kube_exec_auth_role_arn         = local.account["role_arn"]

  kubernetes_config_map_ignore_role_changes = true

  map_additional_iam_roles = [
    {
      rolearn  = local.account["role_arn"],
      username = "admin",
      groups = [
      "system:masters"]
    }
  ]

  context = module.this.context
}

// https://aws.amazon.com/blogs/compute/cost-optimization-and-resilience-eks-with-spot-instances/
module "eks_node_group_light" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.24.0"

  attributes = ["light"]
  additional_tag_map = {
    NodeClass = "light"
    ExtraTag  = "light"
  }

  cluster_name = module.eks_cluster.eks_cluster_id
  subnet_ids   = module.subnets.private_subnet_ids

  instance_types = ["t3.medium"]
  disk_size      = "50"
  disk_type      = "gp3"
  desired_size   = "3"
  min_size       = "3"
  max_size       = "6"

  cluster_autoscaler_enabled = true

  context = module.this.context

  module_depends_on = module.eks_cluster.kubernetes_config_map_id
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
      type : "ingress"
      from_port : 0,
      to_port : 0,
      protocol : -1,
      cidr_blocks : concat(
        module.subnets.private_subnet_cidrs,
        module.subnets.public_subnet_cidrs
      ),
    },
  ]

  context = module.this.context
}

resource "random_string" "loki_bucket" {
  length  = 6
  lower   = true
  upper   = true
  number  = true
  special = false
}

module "loki_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.42.0"

  acl                          = "private"
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  allowed_bucket_actions       = []
  force_destroy                = true
  lifecycle_rules = [
    {
      enabled = true,
      prefix  = "",

      abort_incomplete_multipart_upload_days = 30,

      enable_standard_ia_transition    = true,
      enable_glacier_transition        = true,
      enable_deeparchive_transition    = true,
      enable_current_object_expiration = true,

      standard_transition_days    = 90,
      glacier_transition_days     = 365,
      deeparchive_transition_days = 1095,
      expiration_days             = 3650,

      noncurrent_version_glacier_transition_days     = 90,
      noncurrent_version_deeparchive_transition_days = 365,
      noncurrent_version_expiration_days             = 1095,

      tags = {}
    }
  ]

  user_enabled       = false
  versioning_enabled = true

  s3_replication_enabled = true
  s3_replication_rules = [
    {
      id                 = module.loki_bucket_replication_target.bucket_id
      status             = "Enabled"
      destination_bucket = module.loki_bucket_replication_target.bucket_arn
    }
  ]

  attributes = [random_string.loki_bucket.result, "loki", "main"]
  context    = module.this.context
}

module "loki_bucket_replication_target" {
  providers = {
    aws = aws.dr
  }

  source  = "cloudposse/s3-bucket/aws"
  version = "0.42.0"

  acl                          = "private"
  allow_encrypted_uploads_only = true
  allow_ssl_requests_only      = true
  allowed_bucket_actions       = []
  force_destroy                = true
  lifecycle_rules = [
    {
      enabled = true,
      prefix  = "",

      abort_incomplete_multipart_upload_days = 30,

      enable_standard_ia_transition    = true,
      enable_glacier_transition        = true,
      enable_deeparchive_transition    = true,
      enable_current_object_expiration = true,

      standard_transition_days    = 90,
      glacier_transition_days     = 365,
      deeparchive_transition_days = 1095,
      expiration_days             = 3650,

      noncurrent_version_glacier_transition_days     = 90,
      noncurrent_version_deeparchive_transition_days = 365,
      noncurrent_version_expiration_days             = 1095,

      tags = {}
    }
  ]

  user_enabled       = false
  versioning_enabled = true

  attributes = [random_string.loki_bucket.result, "loki", "dr"]
  context    = module.this.context
}
