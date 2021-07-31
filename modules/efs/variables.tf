variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "worker_security_group_id" {
  type = string
}

variable "cluster_security_group_id" {
  type = string
}

variable "cluster_primary_security_group_id" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
