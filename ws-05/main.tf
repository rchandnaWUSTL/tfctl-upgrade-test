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

resource "kubernetes_namespace_v1" "production" {
  metadata {
    name = "dadgarcorp-production"
    labels = {
      env  = "production"
      team = "platform"
    }
  }
}

removed {
  from = kubernetes_namespace.production
  lifecycle { destroy = false }
}

import {
  to = kubernetes_namespace_v1.production
  id = "dadgarcorp-production"
}

resource "kubernetes_config_map_v1" "nginx" {
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

removed {
  from = kubernetes_config_map.nginx
  lifecycle { destroy = false }
}

import {
  to = kubernetes_config_map_v1.nginx
  id = "dadgarcorp-production/nginx-config"
}

resource "kubernetes_service_account_v1" "app" {
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

removed {
  from = kubernetes_service_account.app
  lifecycle { destroy = false }
}

import {
  to = kubernetes_service_account_v1.app
  id = "dadgarcorp-production/app-sa"
}

resource "kubernetes_secret_v1" "db_creds" {
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

removed {
  from = kubernetes_secret.db_creds
  lifecycle { destroy = false }
}

import {
  to = kubernetes_secret_v1.db_creds
  id = "dadgarcorp-production/db-credentials"
}
