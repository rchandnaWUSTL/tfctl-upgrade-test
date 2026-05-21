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
resource "kubernetes_cluster_role_v1" "admin" {
  metadata {
    name = "dadgarcorp-admin"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

import {
  to = kubernetes_cluster_role_v1.admin
  id = "dadgarcorp-admin"
}

removed {
  from = kubernetes_cluster_role.admin
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_config_map to kubernetes_config_map_v1
resource "kubernetes_config_map_v1" "app" {
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

import {
  to = kubernetes_config_map_v1.app
  id = "default/app-config"
}

removed {
  from = kubernetes_config_map.app
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_namespace to kubernetes_namespace_v1
resource "kubernetes_namespace_v1" "team" {
  metadata {
    name = "dadgarcorp-team"
    labels = {
      team       = "platform"
      managed-by = "terraform"
    }
  }
}

import {
  to = kubernetes_namespace_v1.team
  id = "dadgarcorp-team"
}

removed {
  from = kubernetes_namespace.team
  lifecycle {
    destroy = false
  }
}
