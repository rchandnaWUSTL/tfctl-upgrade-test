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

resource "kubernetes_service_account" "deployer" {
  metadata {
    name      = "deployer-sa"
    namespace = "default"
    labels = {
      app = "deployer"
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_secret" "api_key" {
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

resource "kubernetes_config_map" "env" {
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
