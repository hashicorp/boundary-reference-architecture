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

export BOUNDARY_ADDR=http://localhost:9200
boundary authenticate password -login-name mark -auth-method-id ${module.boundary.boundary_auth_method_id}
# terraform generated password is foofoofoo

#connect to redis
boundary connect -exec redis-cli -target-id ${module.boundary.boundary_redis_target_id} -- -h {{boundary.ip}} -p {{boundary.port}}

EOT
  description = "Boundary Authenticate"
}