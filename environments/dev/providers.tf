provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  assume_role { role_arn = var.aws_role_arn }
}

provider "kubernetes" {
  host                   = module.dev.kubernetes_provider_values.host
  cluster_ca_certificate = module.dev.kubernetes_provider_values.cluster_ca_certificate
  token                  = module.dev.kubernetes_provider_values.token
  config_path            = module.dev.kubernetes_provider_values.config_path
}
