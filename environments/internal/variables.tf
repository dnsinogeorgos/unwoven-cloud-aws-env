# provider
variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

# remote state
variable "aws-org_bucket" {
  type = string
}

variable "aws-org_key" {
  type = string
}

variable "aws-org_region" {
  type = string
}

# VPC
variable "vpc_cidr_block" {
  type = string
}
