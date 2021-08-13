output "account" {
  value = local.account
}

output "github" {
  value     = local.github
  sensitive = true
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

output "loki_bucket" {
  value     = module.loki_bucket
  sensitive = true
}

output "loki_bucket_replication_target" {
  value     = module.loki_bucket_replication_target
  sensitive = true
}
