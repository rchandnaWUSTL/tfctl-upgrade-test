terraform {
  required_version = ">= 1.7.0"
}

variable "workspace_name" {
  type    = string
  default = "unknown"
}

output "migration_status" {
  value = "pre-migration"
}
