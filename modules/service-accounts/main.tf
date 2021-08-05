//data "aws_iam_policy_document" "cluster_autoscaler" {
//  statement {
//    effect    = "Allow"
//    resources = ["*"]
//    actions = [
//      "autoscaling:DescribeAutoScalingGroups",
//      "autoscaling:DescribeAutoScalingInstances",
//      "autoscaling:DescribeLaunchConfigurations",
//      "autoscaling:DescribeTags",
//      "ec2:DescribeLaunchTemplateVersions",
//    ]
//  }
//
//  // TODO: restrict the second statement resources to the ASG ARNs
//  // https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler#aws---iam
//  statement {
//    effect    = "Allow"
//    resources = ["*"]
//    actions = [
//      "autoscaling:SetDesiredCapacity",
//      "autoscaling:TerminateInstanceInAutoScalingGroup",
//      "autoscaling:UpdateAutoScalingGroup",
//    ]
//
//    condition {
//      test     = "StringEquals"
//      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
//      values   = ["true"]
//    }
//
//    condition {
//      test     = "StringEquals"
//      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.eks_cluster_name}"
//      values   = ["owned"]
//    }
//  }
//}
//
//module "cluster_autoscaler_role" {
//  source  = "cloudposse/eks-iam-role/aws"
//  version = "0.10.0"
//
//  enabled                     = var.cluster_autoscaler_enabled
//  aws_iam_policy_document     = data.aws_iam_policy_document.cluster_autoscaler.json
//  aws_account_number          = var.aws_account_id
//  service_account_name        = var.cluster_autoscaler_sa_name
//  service_account_namespace   = var.cluster_autoscaler_namespace
//  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url
//
//  context = module.this.context
//}

data "aws_iam_policy_document" "efs_csi_controller" {
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

module "efs_csi_controller_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.10.0"

  enabled                     = var.efs_csi_controller_enabled
  aws_iam_policy_document     = data.aws_iam_policy_document.efs_csi_controller.json
  aws_account_number          = var.aws_account_id
  service_account_name        = var.efs_csi_controller_sa_name
  service_account_namespace   = var.efs_csi_controller_sa_namespace
  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url

  context = module.this.context
}

data "aws_iam_policy_document" "route53_external_dns" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:route53:::hostedzone/*"]
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
  }
}

module "route53_external_dns_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.10.0"

  enabled                     = var.route53_external_dns_enabled
  aws_iam_policy_document     = data.aws_iam_policy_document.route53_external_dns.json
  aws_account_number          = var.aws_account_id
  service_account_name        = var.route53_external_dns_sa_name
  service_account_namespace   = var.route53_external_dns_sa_namespace
  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url

  context = module.this.context
}
