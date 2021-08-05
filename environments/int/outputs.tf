output "account" {
  value = local.account
}

output "vpc" {
  value     = module.vpc
  sensitive = true
}

output "subnets" {
  value     = module.subnets
  sensitive = true
}

output "efs" {
  value     = module.efs
  sensitive = true
}

output "eks_cluster" {
  value     = module.eks_cluster
  sensitive = true
}

output "eks_node_groups" {
  value = {
    light = module.eks_node_group_light
  }
  sensitive = true
}

output "service_accounts" {
  value     = module.service_accounts
  sensitive = true
}
