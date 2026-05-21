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

# Migrated from kubernetes_namespace to kubernetes_namespace_v1
resource "kubernetes_namespace_v1" "production" {
  metadata {
    name = "dadgarcorp-production"
  }
}

import {
  to = kubernetes_namespace_v1.production
  id = "dadgarcorp-production"
}

removed {
  from = kubernetes_namespace.production
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_config_map to kubernetes_config_map_v1
resource "kubernetes_config_map_v1" "nginx" {
  metadata {
    name      = "nginx-config"
    namespace = "dadgarcorp-production"
  }
}

import {
  to = kubernetes_config_map_v1.nginx
  id = "dadgarcorp-production/nginx-config"
}

removed {
  from = kubernetes_config_map.nginx
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_service_account to kubernetes_service_account_v1
resource "kubernetes_service_account_v1" "app" {
  metadata {
    name      = "app-sa"
    namespace = "dadgarcorp-production"
  }
}

import {
  to = kubernetes_service_account_v1.app
  id = "dadgarcorp-production/app-sa"
}

removed {
  from = kubernetes_service_account.app
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_secret to kubernetes_secret_v1
resource "kubernetes_secret_v1" "db_creds" {
  metadata {
    name      = "db-credentials"
    namespace = "dadgarcorp-production"
  }
}

import {
  to = kubernetes_secret_v1.db_creds
  id = "dadgarcorp-production/db-credentials"
}

removed {
  from = kubernetes_secret.db_creds
  lifecycle {
    destroy = false
  }
}
