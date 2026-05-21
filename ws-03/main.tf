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

resource "kubernetes_cluster_role_v1" "readonly" {
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

removed {
  from = kubernetes_cluster_role.readonly
  lifecycle { destroy = false }
}

import {
  to = kubernetes_cluster_role_v1.readonly
  id = "dadgarcorp-readonly"
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "dadgarcorp-monitoring"
    labels = {
      team    = "sre"
      purpose = "monitoring"
    }
  }
}

removed {
  from = kubernetes_namespace.monitoring
  lifecycle { destroy = false }
}

import {
  to = kubernetes_namespace_v1.monitoring
  id = "dadgarcorp-monitoring"
}

resource "kubernetes_config_map_v1" "prometheus" {
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

removed {
  from = kubernetes_config_map.prometheus
  lifecycle { destroy = false }
}

import {
  to = kubernetes_config_map_v1.prometheus
  id = "dadgarcorp-monitoring/prometheus-config"
}
