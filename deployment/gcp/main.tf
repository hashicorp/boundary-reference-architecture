# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


module "gcp" {
  source       = "./gcp"
  enable_ssh   = true
  ssh_key_path = var.ssh_key
  location     = var.region
  project      = var.project
  my_public_ip = "72.194.116.166/32"
}

# module "debugging_example" {
# 	module "gcp" {
#   source       = "./gcp"
#   enable_ssh   = true
#   ssh_key_path = "/Users/grant/.ssh/id_rsa.pub"
#   my_public_ip = "17.42.249.192/32"
# }

# module "custom_ports" {
# 	module "gcp" {
#   source       = "./gcp"
# 	controller_api_port = 9210
# 	controller_cluster_port = 9211
# 	worker_port = 9212
# }
