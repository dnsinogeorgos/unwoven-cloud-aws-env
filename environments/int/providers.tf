provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = local.account["role_arn"]
  }
}

provider "aws" {
  alias  = "dr"
  region = var.aws_region_dr

  assume_role {
    role_arn = local.account["role_arn"]
  }
}
