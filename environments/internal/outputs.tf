output "efs" {
  value = module.efs
}

output "eks_cluster" {
  value = module.eks_cluster
}

output "eks_node_group" {
  value = module.eks_node_group
}

output "state" {
  value = local.state
}
