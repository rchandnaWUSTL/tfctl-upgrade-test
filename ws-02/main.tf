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
resource "kubernetes_service_account_v1" "deployer" {
  metadata {
    name      = "deployer-sa"
    namespace = "default"
  }
}

import {
  to = kubernetes_service_account_v1.deployer
  id = "default/deployer-sa"
}

removed {
  from = kubernetes_service_account.deployer
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_secret to kubernetes_secret_v1
resource "kubernetes_secret_v1" "api_key" {
  metadata {
    name      = "api-key"
    namespace = "default"
  }
}

import {
  to = kubernetes_secret_v1.api_key
  id = "default/api-key"
}

removed {
  from = kubernetes_secret.api_key
  lifecycle {
    destroy = false
  }
}

# Migrated from kubernetes_config_map to kubernetes_config_map_v1
resource "kubernetes_config_map_v1" "env" {
  metadata {
    name      = "env-config"
    namespace = "default"
  }
}

import {
  to = kubernetes_config_map_v1.env
  id = "default/env-config"
}

removed {
  from = kubernetes_config_map.env
  lifecycle {
    destroy = false
  }
}
