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

  // Changing the config map after deployment requires a tricky workaround
  // https://registry.terraform.io/modules/cloudposse/eks-cluster/aws/latest
  //
  // To change the configmap after deployment, the following must be
  // disabled, changes must be planned and state moved as below.
  // terraform state mv 'module.eks_cluster.kubernetes_config_map.aws_auth_ignore_changes[0]' 'module.eks_cluster.kubernetes_config_map.aws_auth[0]'
  // Same for enabling again from disabled
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

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = module.eks_cluster.eks_cluster_id
  resolve_conflicts = "OVERWRITE"
  addon_name        = "vpc-cni"
  addon_version     = "v1.9.0-eksbuild.1"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks_cluster.eks_cluster_id
  resolve_conflicts = "OVERWRITE"
  addon_name        = "coredns"
  addon_version     = "v1.8.4-eksbuild.1"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks_cluster.eks_cluster_id
  resolve_conflicts = "OVERWRITE"
  addon_name        = "kube-proxy"
  addon_version     = "v1.21.2-eksbuild.2"
}

// https://aws.amazon.com/blogs/compute/cost-optimization-and-resilience-eks-with-spot-instances/
module "eks_node_group_amd64_gp" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.24.0"

  attributes = ["amd64"]
  additional_tag_map = {
    NodeClass = "amd64"
    ExtraTag  = "amd64"
  }

  cluster_name = module.eks_cluster.eks_cluster_id
  subnet_ids   = module.subnets.private_subnet_ids

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]
  disk_size      = "50"
  disk_type      = "gp3"
  min_size       = "3"
  desired_size   = "3"
  max_size       = "6"

  cluster_autoscaler_enabled = true

  context = module.this.context

  module_depends_on = module.eks_cluster.kubernetes_config_map_id
}

//module "eks_node_group_arm64_gp" {
//  source  = "cloudposse/eks-node-group/aws"
//  version = "0.24.0"
//
//  attributes = ["arm64"]
//  additional_tag_map = {
//    NodeClass = "arm64"
//    ExtraTag  = "arm64"
//  }
//
//  cluster_name = module.eks_cluster.eks_cluster_id
//  subnet_ids   = module.subnets.private_subnet_ids
//
//  ami_type       = "AL2_ARM_64"
//  instance_types = ["t4g.medium"]
//  disk_size      = "50"
//  disk_type      = "gp3"
//  min_size       = "3"
//  desired_size   = "3"
//  max_size       = "6"
//
//  cluster_autoscaler_enabled = true
//
//  context = module.this.context
//
//  module_depends_on = module.eks_cluster.kubernetes_config_map_id
//}

// S3 resources
resource "random_string" "bucket" {
  length  = 6
  lower   = true
  upper   = false
  number  = true
  special = false
}

module "buckets_loki" {
  providers = {
    aws.main = aws
    aws.dr   = aws.dr
  }

  source = "../../modules/replicated-s3-bucket"

  attributes = [random_string.bucket.result, "loki"]

  context = module.this.context
}

module "buckets_thanos" {
  providers = {
    aws.main = aws
    aws.dr   = aws.dr
  }

  source = "../../modules/replicated-s3-bucket"

  attributes = [random_string.bucket.result, "thanos"]

  context = module.this.context
}
