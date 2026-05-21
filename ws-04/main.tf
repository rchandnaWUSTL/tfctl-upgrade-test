terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_service_account" "ci" {
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

resource "kubernetes_secret" "tls_cert" {
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

resource "kubernetes_cluster_role" "developer" {
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
