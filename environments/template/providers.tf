provider "aws" {
  region = var.aws_region
  assume_role { role_arn = local.state["role_arn"] }
}
