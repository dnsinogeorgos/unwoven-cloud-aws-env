variable "environment" {
  type = string
}

variable "cidr" {
  type = string
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
  type = string
}

variable "customer_gateways" {
  type = map(map(any))
}

variable "customer_gateway_tags" {
  type = map(string)
}

variable "tags_subnet_internal" {
  type    = map(string)
  default = {}
}

variable "tags_subnet_public" {
  type    = map(string)
  default = {}
}

variable "tags_vpc" {
  type    = map(string)
  default = {}
}
