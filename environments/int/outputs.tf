output "state" {
  value = local.state
}

output "vpc" {
  value = module.vpc
}

output "subnets" {
  value = module.subnets
}

output "efs" {
  value = module.efs
}

output "eks_cluster" {
  value = module.eks_cluster
}

output "eks_node_groups" {
  value = {
    light = module.eks_node_group_light
  }
}

output "eks_efs_role" {
  value = module.eks_efs_role
}
