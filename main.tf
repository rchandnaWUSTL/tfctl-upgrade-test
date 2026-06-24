terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for payments service"
}

# S3 bucket for payments service data
resource "aws_s3_bucket" "payments" {
  bucket = var.bucket_name

  tags = {
    environment = var.environment
    service     = "payments-api"
    managed_by  = "terraform"
  }
}

# Versioning enabled — correct value
resource "aws_s3_bucket_versioning" "payments" {
  bucket = aws_s3_bucket.payments.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "payments" {
  bucket = aws_s3_bucket.payments.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "payments" {
  bucket = aws_s3_bucket.payments.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

data "aws_caller_identity" "current" {}

output "bucket_arn" {
  value       = aws_s3_bucket.payments.arn
  description = "ARN of the payments S3 bucket"
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID"
}
