terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.52"

      configuration_aliases = [aws.main, aws.dr]
    }
  }
}
