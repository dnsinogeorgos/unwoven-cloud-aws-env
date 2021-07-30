terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  required_version = "~> 1.0"
}
