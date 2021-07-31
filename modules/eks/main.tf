resource "aws_kms_key" "eks" {
  description = "${var.cluster_name} kms secret encryption"
}

locals {
  eks_tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
  tags = merge(var.tags, local.eks_tags)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.admin_cidrs
  cluster_enabled_log_types            = var.cluster_enabled_log_types
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  cluster_create_security_group = true
  worker_create_security_group  = true

  enable_irsa = true

  tags = local.tags

  node_groups_defaults = {
    disk_size = 100
  }

  node_groups = var.node_groups

  map_users                                    = var.map_users
  map_roles                                    = var.map_roles
  kubeconfig_aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  kubeconfig_aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  config_path            = module.eks.kubeconfig_filename
}

data "aws_iam_policy_document" "eks_node_groups" {
  count = signum(length([for k, v in var.node_groups : k]))

  statement {
    sid       = "eksWorkerAutoscalingAll"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }

  statement {
    sid       = "eksWorkerAutoscalingOwn"
    effect    = "Allow"
    resources = [for ng in module.eks.node_groups : ng.arn]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }

  depends_on = [module.eks.cluster_id]
}

resource "aws_iam_policy" "eks_node_groups" {
  count = signum(length([for k, v in var.node_groups : k]))

  name   = "eks_node_groups"
  policy = data.aws_iam_policy_document.eks_node_groups.0.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_node_groups" {
  count = signum(length([for k, v in var.node_groups : k]))

  policy_arn = aws_iam_policy.eks_node_groups.0.arn
  role       = module.eks.worker_iam_role_name
}
