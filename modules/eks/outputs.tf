output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "worker_security_group_id" {
  value = module.eks.worker_security_group_id
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "kubernetes_provider_values" {
  value = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    config_path            = module.eks.kubeconfig_filename
  }
}
