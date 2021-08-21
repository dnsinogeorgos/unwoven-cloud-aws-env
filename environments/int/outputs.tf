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
    amd64 = module.eks_node_group_amd64_gp
    //    arm64 = module.eks_node_group_arm64_gp
  }
  sensitive = true
}

output "buckets_loki" {
  value     = module.buckets_loki.buckets
  sensitive = true
}

output "buckets_thanos" {
  value     = module.buckets_thanos.buckets
  sensitive = true
}
