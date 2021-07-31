provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  assume_role { role_arn = data.terraform_remote_state.aws-org.outputs.accounts.internal.role_arn }
}
