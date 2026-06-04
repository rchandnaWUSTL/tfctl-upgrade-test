terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "cluster_name" {
  type    = string
  default = "dadgarcorp-demo"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

# Endpoint + CA are passed in (sourced from the cluster), so the run does not
# need eks:DescribeCluster. The provider only mints a short-lived token via
# aws_eks_cluster_auth, which needs nothing beyond STS.
variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_cert" {
  type = string
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "dadgarcorp-ws37"
    labels = {
      managed-by = "terraform"
      demo       = "k8s-migration"
    }
  }
}

resource "kubernetes_config_map" "app" {
  metadata {
    name      = "app-config"
    namespace = "dadgarcorp-ws37"
    labels = {
      app        = "dadgarcorp"
      managed-by = "terraform"
    }
  }
  data = {
    environment = "production"
    log_level   = "info"
    version     = "2.1.0"
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name      = "deployer"
    namespace = "dadgarcorp-ws37"
    labels = {
      managed-by = "terraform"
    }
  }
}
