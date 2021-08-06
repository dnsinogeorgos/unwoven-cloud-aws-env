output "cluster_autoscaler_role" {
  value = module.cluster_autoscaler_role
}

output "efs_csi_driver_role" {
  value = module.efs_csi_driver_role
}

output "route53_cert_manager_role" {
  value = module.route53_cert_manager_role
}

output "route53_external_dns_role" {
  value = module.route53_external_dns_role
}
