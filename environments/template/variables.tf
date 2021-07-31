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

//variable "template" {
//  description = "template variable"
//  default     = "template default value"
//}
