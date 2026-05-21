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

# Migrated: kubernetes_service_account -> kubernetes_service_account_v1
resource "kubernetes_service_account_v1" "deployer" {
  metadata {
    name      = "deployer-sa"
    namespace = "default"
    labels = {
      app = "deployer"
    }
  }
  automount_service_account_token = true
}

removed {
  from = kubernetes_service_account.deployer
  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_service_account_v1.deployer
  id = "default/deployer-sa"
}

# Migrated: kubernetes_secret -> kubernetes_secret_v1
resource "kubernetes_secret_v1" "api_key" {
  metadata {
    name      = "api-key"
    namespace = "default"
    labels = {
      app = "dadgarcorp"
    }
  }
  data = {
    api_key = "REDACTED"
  }
  type = "Opaque"
}

removed {
  from = kubernetes_secret.api_key
  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_secret_v1.api_key
  id = "default/api-key"
}

# Migrated: kubernetes_config_map -> kubernetes_config_map_v1
resource "kubernetes_config_map_v1" "env" {
  metadata {
    name      = "env-config"
    namespace = "default"
    labels = {
      app = "dadgarcorp"
    }
  }
  data = {
    DATABASE_URL = "postgres://db.internal:5432/app"
    REDIS_URL    = "redis://cache.internal:6379"
  }
}

removed {
  from = kubernetes_config_map.env
  lifecycle {
    destroy = false
  }
}

import {
  to = kubernetes_config_map_v1.env
  id = "default/env-config"
}
