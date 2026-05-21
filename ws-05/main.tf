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

resource "kubernetes_namespace" "production" {
  metadata {
    name = "dadgarcorp-production"
    labels = {
      env  = "production"
      team = "platform"
    }
  }
}

resource "kubernetes_config_map" "nginx" {
  metadata {
    name      = "nginx-config"
    namespace = "dadgarcorp-production"
    labels = {
      app = "nginx"
    }
  }
  data = {
    worker_connections = "4096"
    keepalive_timeout  = "65"
    proxy_read_timeout = "300"
  }
}

resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "dadgarcorp-production"
    labels = {
      app = "dadgarcorp"
      env = "production"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::650169680785:role/dadgarcorp-app"
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_secret" "db_creds" {
  metadata {
    name      = "db-credentials"
    namespace = "dadgarcorp-production"
    labels = {
      app = "dadgarcorp"
    }
  }
  data = {
    username = "REDACTED"
    password = "REDACTED"
    host     = "REDACTED"
  }
  type = "Opaque"
}
