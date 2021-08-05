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

//output "cluster_autoscaler_role" {
//  value     = module.service_accounts.cluster_autoscaler_role
//  sensitive = true
//}

output "efs_csi_controller_role" {
  value     = module.service_accounts.efs_csi_controller_role
  sensitive = true
}

output "route53_external_dns_role" {
  value     = module.service_accounts.route53_external_dns_role
  sensitive = true
}
