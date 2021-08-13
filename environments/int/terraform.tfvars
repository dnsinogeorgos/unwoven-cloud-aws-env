# provider
aws_region    = "eu-central-1"
aws_region_dr = "eu-west-3"

# remote state
aws-org_bucket = "unwoven-state"
aws-org_key    = "aws-org"
aws-org_region = "eu-central-1"

# context
namespace = "int"
tags = {
  Terraform = "true"
  Namespace = "int"
}
