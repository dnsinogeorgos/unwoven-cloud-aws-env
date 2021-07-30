variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_role_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "single_nat_gateway" {
  type = bool
}

variable "one_nat_gateway_per_az" {
  type = bool
}

variable "amazon_side_asn" {
  type = string
}

variable "customer_gateways" {
  type = map(map(any))
}

variable "customer_gateway_tags" {
  type = map(string)
}

variable "cluster_enabled_log_types" {
  type = list(string)
}

variable "node_groups" {
  type = map(any)
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}
