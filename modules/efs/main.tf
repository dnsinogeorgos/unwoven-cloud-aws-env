// https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.31.0"

  security_group_enabled = true
  security_group_rules = [
    {
      "type" : "ingress"
      "from_port" : 0,
      "to_port" : 0,
      "protocol" : -1,
      "cidr_blocks" : [var.vpc_cidr_block],
    },
  ]
  encrypted = true
  region    = var.aws_region
  security_groups = [
    var.worker_security_group_id,
    var.cluster_security_group_id,
    var.cluster_primary_security_group_id
  ]
  subnets = var.subnets
  vpc_id  = var.vpc_id

  name = "${var.environment}-efs"

  tags = var.tags
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

resource "aws_iam_policy" "efs_csi_driver" {
  name   = "AmazonEKS_EFS_CSI_Driver_Policy"
  policy = data.aws_iam_policy_document.efs_csi_driver.json

  tags = var.tags
}

locals {
  cluster_oidc_issuer_url = replace(var.cluster_oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "efs_csi_driver_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "efs_csi_driver_role" {
  name               = "AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  policy_arn = aws_iam_policy.efs_csi_driver.arn
  role       = aws_iam_role.efs_csi_driver_role.name
}
