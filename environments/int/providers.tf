provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = local.account["role_arn"]
  }
}
