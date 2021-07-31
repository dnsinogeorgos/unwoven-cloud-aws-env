variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "admin_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "single_nat_gateway" {
  type = bool
}

variable "one_nat_gateway_per_az" {
  type = bool
}

variable "amazon_side_asn" {
  type    = string
  default = "64512"
}

variable "customer_gateways" {
  type    = map(map(any))
  default = {}
}

variable "customer_gateway_tags" {
  type    = map(string)
  default = {}
}

variable "cluster_enabled_log_types" {
  type = list(string)
}

variable "node_groups" {
  type = map(any)
}

variable "map_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "kubeconfig_aws_authenticator_additional_args" {
  type    = list(string)
  default = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
