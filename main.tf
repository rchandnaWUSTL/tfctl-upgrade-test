terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "replica_count" {
  type    = number
  default = 3
}

resource "null_resource" "payments_api" {
  triggers = {
    service     = "payments-api"
    environment = var.environmnet
    replicas    = var.replica_count
  }
}

output "service" {
  value = "payments-api (${var.environment})"
}
