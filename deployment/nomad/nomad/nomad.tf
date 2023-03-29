terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "1.4.17"
    }
  }
}

provider "nomad" {
  address = var.nomad_address
}
