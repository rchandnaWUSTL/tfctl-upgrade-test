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

resource "kubernetes_service_account_v1" "ci" {
  metadata {
    name      = "ci-runner"
    namespace = "default"
    labels = {
      app  = "ci"
      team = "devops"
    }
    annotations = {
      "kubernetes.io/enforce-mountable-secrets" = "true"
    }
  }
  automount_service_account_token = true
  image_pull_secret {
    name = "registry-creds"
  }
}

removed {
  from = kubernetes_service_account.ci
  lifecycle { destroy = false }
}

import {
  to = kubernetes_service_account_v1.ci
  id = "default/ci-runner"
}

resource "kubernetes_secret_v1" "tls_cert" {
  metadata {
    name      = "tls-cert"
    namespace = "default"
    labels = {
      app = "ingress"
    }
  }
  data = {
    "tls.crt" = "REDACTED"
    "tls.key" = "REDACTED"
  }
  type = "kubernetes.io/tls"
}

removed {
  from = kubernetes_secret.tls_cert
  lifecycle { destroy = false }
}

import {
  to = kubernetes_secret_v1.tls_cert
  id = "default/tls-cert"
}

resource "kubernetes_cluster_role_v1" "developer" {
  metadata {
    name = "dadgarcorp-developer"
    labels = {
      role = "developer"
    }
  }
  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["pods", "deployments", "jobs", "cronjobs"]
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
  }
}

removed {
  from = kubernetes_cluster_role.developer
  lifecycle { destroy = false }
}

import {
  to = kubernetes_cluster_role_v1.developer
  id = "dadgarcorp-developer"
}
