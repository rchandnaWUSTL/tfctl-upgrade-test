terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "service_name" {
  type    = string
  default = "payments-api"

resource "null_resource" "payments_api" {
  triggers = {
    service     = var.service_name
    environment = var.environment
    replicas    = 3
  }
}

resource "null_resource" "payments_db" {
  triggers = {
    service = "${var.service_name}-db"
    engine  = "postgres"
  }
}

output "service" {
  value = var.service_name
}
