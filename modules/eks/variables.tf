variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "admin_cidrs" {
  type = list(string)
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
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "kubeconfig_aws_authenticator_additional_args" {
  type = list(string)
}

variable "kubeconfig_aws_authenticator_env_variables" {
  type = map(string)
}
