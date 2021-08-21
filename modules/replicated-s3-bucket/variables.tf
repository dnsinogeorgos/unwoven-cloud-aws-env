variable "acl" {
  type        = string
  default     = "private"
  description = "The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply. We recommend `private` to avoid exposing sensitive information. Conflicts with `grants`."
}

variable "allow_encrypted_uploads_only" {
  type        = bool
  default     = true
  description = "Set to `true` to prevent uploads of unencrypted objects to S3 bucket"
}

variable "allow_ssl_requests_only" {
  type        = bool
  default     = true
  description = "Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
}

variable "allowed_bucket_actions" {
  type        = list(string)
  default     = []
  description = "List of actions the user is permitted to perform on the S3 bucket"
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
}

variable "lifecycle_rules" {
  type = list(object({
    prefix  = string
    enabled = bool
    tags    = map(string)

    enable_glacier_transition        = bool
    enable_deeparchive_transition    = bool
    enable_standard_ia_transition    = bool
    enable_current_object_expiration = bool

    abort_incomplete_multipart_upload_days         = number
    noncurrent_version_glacier_transition_days     = number
    noncurrent_version_deeparchive_transition_days = number
    noncurrent_version_expiration_days             = number

    standard_transition_days    = number
    glacier_transition_days     = number
    deeparchive_transition_days = number
    expiration_days             = number
  }))
  default = [{
    enabled = true,
    prefix  = "",

    abort_incomplete_multipart_upload_days = 30,

    enable_standard_ia_transition    = true,
    enable_glacier_transition        = true,
    enable_deeparchive_transition    = true,
    enable_current_object_expiration = true,

    standard_transition_days    = 90,
    glacier_transition_days     = 365,
    deeparchive_transition_days = 1095,
    expiration_days             = 3650,

    noncurrent_version_glacier_transition_days     = 90,
    noncurrent_version_deeparchive_transition_days = 365,
    noncurrent_version_expiration_days             = 1095,

    tags = {}
  }]
  description = "A list of lifecycle rules"
}

variable "user_enabled" {
  type        = bool
  default     = false
  description = "Set to `true` to create an IAM user with permission to access the bucket"
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
}
