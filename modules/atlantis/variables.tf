variable "vpc_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "atlantis_gh_user" {
  type = string
}

variable "atlantis_gh_team_whitelist" {
  type = string
}

variable "atlantis_repo_whitelist" {
  type = list(string)
}

variable "parent_zone_id" {
  type = string
}

variable "github_oauth_token" {
  type = string
}

variable "github_webhooks_token" {
  type = string
}

variable "repo_owner" {
  type = string
}

variable "repo_name" {
  type = string
}
