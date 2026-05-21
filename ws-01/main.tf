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

resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "dadgarcorp-admin"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_config_map" "app" {
  metadata {
    name      = "app-config"
    namespace = "default"
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

resource "kubernetes_namespace" "team" {
  metadata {
    name = "dadgarcorp-team"
    labels = {
      team       = "platform"
      managed-by = "terraform"
    }
  }
}
