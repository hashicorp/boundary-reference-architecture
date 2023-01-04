# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "boundary_addr" {
  default = "http://127.0.0.1:9200"
}

module "kubernetes" {
  source = "./kubernetes"
}

module "boundary" {
  source = "./boundary"
  addr   = var.boundary_addr
}

output "boundary_auth_method_id" {
  value = module.boundary.boundary_auth_method_password
}

output "boundary_connect_syntax" {
  value       = <<EOT

# https://learn.hashicorp.com/tutorials/boundary/oss-getting-started-connect?in=boundary/oss-getting-started

boundary authenticate password -login-name mark -auth-method-id ${module.boundary.boundary_auth_method_password}

EOT
  description = "Boundary Authenticate"
}