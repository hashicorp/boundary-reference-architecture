# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## We use this to append a unique id on the end of our names to prevent collisions.
resource "random_id" "this" {
  byte_length = 8
}

data "google_compute_zones" "this" {
}

## We are using locals here for a couple of purposes. The first is to render
## out our config file. We do this once with a number of conditions so that we
## only have to maintain the inputs in one place, and then apply it to both
## our workers and controllers.
## The second purpose is to have somewhere you can easily update your naming
## conventions should you choose to do so.

locals {
  boundary_name = "boundary-${random_id.this.hex}"

  boundary_controller_name         = "${local.boundary_name}-controller"
  boundary_controller_api_name     = "${local.boundary_name}-controller-api"
  boundary_controller_cluster_name = "${local.boundary_name}-controller-cluster"

  boundary_worker_name = "${local.boundary_name}-worker"

  boundary_root_key_name        = "${local.boundary_name}-root"
  boundary_worker_auth_key_name = "${local.boundary_name}-worker-auth"
  boundary_recovery_key_name    = "${local.boundary_name}-recovery"

  ssh_key_string = var.ssh_key_path != "" ? "${var.ssh_username}:${file(var.ssh_key_path)}" : null
}
