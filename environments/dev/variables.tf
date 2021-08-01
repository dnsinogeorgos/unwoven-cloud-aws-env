variable "aws_region" {
  type = string
}

variable "aws-org_bucket" {
  type = string
}

variable "aws-org_key" {
  type = string
}

variable "aws-org_region" {
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

variable "cluster_enabled_log_types" {
  type = list(string)
}

variable "node_groups" {
  type = map(any)
}
