terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "AWS region for demo resources"
}

variable "environment" {
  type        = string
  description = "Environment name"
  sensitive   = false
}

locals {
  workspace_tags = {
    environment       = var.environment
    managed_by        = "terraform"
    terraform_version = "1.6.x"
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID for verification"
}

output "environment" {
  value       = var.environment
  description = "Current environment"
}

