terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 1.2.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.12"
    }
  }
  required_version = ">= 0.13"
}
