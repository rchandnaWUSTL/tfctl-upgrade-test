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

# Migrated from kubernetes_cluster_role to kubernetes_cluster_role_v1
resource "kubernetes_cluster_role_v1" "readonly" {
  metadata {
    name = "dadgarcorp-readonly"
  }
}

import {
  to = kubernetes_cluster_role_v1.readonly
  id = "dadgarcorp-readonly"
}

removed {
  from = kubernetes_cluster_role.readonly
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_namespace to kubernetes_namespace_v1
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "dadgarcorp-monitoring"
  }
}

import {
  to = kubernetes_namespace_v1.monitoring
  id = "dadgarcorp-monitoring"
}

removed {
  from = kubernetes_namespace.monitoring
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_config_map to kubernetes_config_map_v1
resource "kubernetes_config_map_v1" "prometheus" {
  metadata {
    name      = "prometheus-config"
    namespace = "dadgarcorp-monitoring"
  }
}

import {
  to = kubernetes_config_map_v1.prometheus
  id = "dadgarcorp-monitoring/prometheus-config"
}

removed {
  from = kubernetes_config_map.prometheus
  lifecycle {
    destroy = false
  }
}
