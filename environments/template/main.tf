terraform {
  backend "s3" {
    encrypt = true
  }
}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "aws-org" {
  backend = "s3"
  config = {
    bucket = var.aws-org_bucket
    key    = var.aws-org_key
    region = var.aws-org_region
  }
}

//resource "random_integer" "template" {
//  count = module.this.enabled ? 1 : 0
//
//  min = 1
//  max = 50000
//  keepers = {
//    example = var.template
//  }
//}

//locals {
//  template = format("%v %v", var.template, join("", random_integer.template[*].result))
//}
