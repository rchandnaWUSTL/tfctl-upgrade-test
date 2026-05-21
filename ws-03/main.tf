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

resource "kubernetes_cluster_role" "readonly" {
  metadata {
    name = "dadgarcorp-readonly"
    labels = {
      role = "readonly"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "dadgarcorp-monitoring"
    labels = {
      team    = "sre"
      purpose = "monitoring"
    }
  }
}

resource "kubernetes_config_map" "prometheus" {
  metadata {
    name      = "prometheus-config"
    namespace = "dadgarcorp-monitoring"
    labels = {
      app = "prometheus"
    }
  }
  data = {
    scrape_interval     = "30s"
    evaluation_interval = "30s"
    retention           = "15d"
  }
}
