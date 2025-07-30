provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = ">= 1.0.0"
    }
  }
}