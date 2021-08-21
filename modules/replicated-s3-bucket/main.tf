module "bucket_main" {
  providers = {
    aws = aws.main
  }

  source  = "cloudposse/s3-bucket/aws"
  version = "0.42.0"

  acl                          = var.acl
  allow_encrypted_uploads_only = var.allow_ssl_requests_only
  allow_ssl_requests_only      = var.allow_ssl_requests_only
  allowed_bucket_actions       = var.allowed_bucket_actions
  force_destroy                = var.force_destroy
  lifecycle_rules              = var.lifecycle_rules

  user_enabled       = var.user_enabled
  versioning_enabled = var.versioning_enabled

  s3_replication_enabled = true
  s3_replication_rules = [
    {
      id                 = module.bucket_dr.bucket_id
      status             = "Enabled"
      destination_bucket = module.bucket_dr.bucket_arn
    }
  ]

  attributes = concat(var.attributes, ["main"])
  context    = module.this.context
}

module "bucket_dr" {
  providers = {
    aws = aws.dr
  }

  source  = "cloudposse/s3-bucket/aws"
  version = "0.42.0"

  acl                          = var.acl
  allow_encrypted_uploads_only = var.allow_ssl_requests_only
  allow_ssl_requests_only      = var.allow_ssl_requests_only
  allowed_bucket_actions       = var.allowed_bucket_actions
  force_destroy                = var.force_destroy
  lifecycle_rules              = var.lifecycle_rules

  user_enabled       = var.user_enabled
  versioning_enabled = var.versioning_enabled

  attributes = concat(var.attributes, ["dr"])
  context    = module.this.context
}
