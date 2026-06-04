terraform {
  required_version = ">= 1.7.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "id" {
  length  = 12
  special = false
}

resource "terraform_data" "marker" {
  input = "no kubernetes resources here"
}
