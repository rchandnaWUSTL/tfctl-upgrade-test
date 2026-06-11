terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
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

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "dadgarcorp-ws14"
    labels = {
      managed-by = "terraform"
      demo       = "k8s-migration"
    }
  }
}

resource "kubernetes_config_map_v1" "app" {
  metadata {
    name      = "app-config"
    namespace = "dadgarcorp-ws14"
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

resource "kubernetes_service_account_v1" "sa" {
  metadata {
    name      = "deployer"
    namespace = "dadgarcorp-ws14"
    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_secret_v1" "creds" {
  metadata {
    name      = "db-creds"
    namespace = "dadgarcorp-ws14"
  }
  data = {
    token = "s3cr3t-db-creds"
  }
  type = "Opaque"
}

# --- migration: import existing objects into versioned types ---
import {
  to = kubernetes_namespace_v1.ns
  id = "dadgarcorp-ws14"
}

import {
  to = kubernetes_config_map_v1.app
  id = "dadgarcorp-ws14/app-config"
}

import {
  to = kubernetes_service_account_v1.sa
  id = "dadgarcorp-ws14/deployer"
}

import {
  to = kubernetes_secret_v1.creds
  id = "dadgarcorp-ws14/db-creds"
}

# --- migration: release old types from state (no destroy) ---
removed {
  from = kubernetes_namespace.ns
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_config_map.app
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_service_account.sa
  lifecycle {
    destroy = false
  }
}

removed {
  from = kubernetes_secret.creds
  lifecycle {
    destroy = false
  }
}
