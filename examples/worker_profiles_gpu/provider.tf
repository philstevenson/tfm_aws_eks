terraform {
  required_providers {
    kubernetes = {
      version = "~> 2.0.2"
    }
    helm = {
      version = "2.0.2"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "eu-west-1"
}
