provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  assume_role { role_arn = var.aws_role_arn }

  default_tags {
    tags = {
      Terraform   = "true"
      Module      = "unwoven-cloud-aws-env"
      Environment = var.environment
    }
  }
}
