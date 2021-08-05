//output "cluster_autoscaler_role" {
//  value = module.efs_csi_controller_role
//}

output "efs_csi_controller_role" {
  value = module.efs_csi_controller_role
}

output "route53_external_dns_role" {
  value = module.route53_external_dns_role
}
