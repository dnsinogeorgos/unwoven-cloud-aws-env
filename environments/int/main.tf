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
  account    = data.terraform_remote_state.aws-org.outputs.accounts[var.namespace]
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

  kube_data_auth_enabled          = false
  kube_exec_auth_enabled          = true
  kube_exec_auth_role_arn_enabled = true
  kube_exec_auth_role_arn         = local.account["role_arn"]

  // beware of dirty hax to disable and enable this
  // https://registry.terraform.io/modules/cloudposse/eks-cluster/aws/latest
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

  instance_types = ["t3.small"]
  disk_size      = "50"
  disk_type      = "gp3"
  desired_size   = "3"
  min_size       = "1"
  max_size       = "6"

  cluster_autoscaler_enabled        = true
  worker_role_autoscale_iam_enabled = true

  context = module.this.context

  module_depends_on = module.eks_cluster.kubernetes_config_map_id
}

data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "elasticfilesystem:CreateAccessPoint",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }


  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "elasticfilesystem:DeleteAccessPoint",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}

module "eks_efs_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.10.0"

  aws_account_number          = local.account["account_id"]
  eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer

  service_account_name      = "efs-csi-controller-sa"
  service_account_namespace = "kube-system"
  aws_iam_policy_document   = data.aws_iam_policy_document.efs_csi_driver.json
}
