terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Usar una versión reciente
    }
  }
}

provider "aws" {
  region = var.aws_region
}