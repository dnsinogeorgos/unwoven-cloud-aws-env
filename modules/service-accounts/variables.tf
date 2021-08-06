variable "aws_account_id" {
  type = string
}

variable "route53_zone_id" {
  type    = string
  default = ""
}

variable "eks_cluster_oidc_issuer_url" {
  type = string
}

# cluster-autoscaler
variable "cluster_autoscaler_enabled" {
  type    = bool
  default = false
}

variable "cluster_autoscaler_sa_name" {
  type    = string
  default = "cluster-autoscaler-sa"
}

variable "cluster_autoscaler_namespace" {
  type    = string
  default = "cluster-autoscaler"
}

# aws-efs-csi-driver
variable "efs_csi_driver_enabled" {
  type    = bool
  default = false
}

variable "efs_csi_driver_sa_name" {
  type    = string
  default = "efs-csi-driver-sa"
}

variable "efs_csi_driver_sa_namespace" {
  type    = string
  default = "efs-csi-driver"
}

# cert-manager
variable "route53_cert_manager_enabled" {
  type    = bool
  default = false
}

variable "route53_cert_manager_sa_name" {
  type    = string
  default = "cert-manager-sa"
}

variable "route53_cert_manager_sa_namespace" {
  type    = string
  default = "cert-manager"
}

# external-dns
variable "route53_external_dns_enabled" {
  type    = bool
  default = false
}

variable "route53_external_dns_sa_name" {
  type    = string
  default = "external-dns-sa"
}

variable "route53_external_dns_sa_namespace" {
  type    = string
  default = "external-dns"
}
