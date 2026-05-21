terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Migrated from kubernetes_service_account to kubernetes_service_account_v1
resource "kubernetes_service_account_v1" "ci" {
  metadata {
    name      = "ci-runner"
    namespace = "default"
  }
}

import {
  to = kubernetes_service_account_v1.ci
  id = "default/ci-runner"
}

removed {
  from = kubernetes_service_account.ci
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_secret to kubernetes_secret_v1
resource "kubernetes_secret_v1" "tls_cert" {
  metadata {
    name      = "tls-cert"
    namespace = "default"
  }
}

import {
  to = kubernetes_secret_v1.tls_cert
  id = "default/tls-cert"
}

removed {
  from = kubernetes_secret.tls_cert
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_cluster_role to kubernetes_cluster_role_v1
resource "kubernetes_cluster_role_v1" "developer" {
  metadata {
    name = "dadgarcorp-developer"
  }
}

import {
  to = kubernetes_cluster_role_v1.developer
  id = "dadgarcorp-developer"
}

removed {
  from = kubernetes_cluster_role.developer
  lifecycle {
    destroy = false
  }
}
