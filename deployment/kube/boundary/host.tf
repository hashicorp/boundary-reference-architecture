# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "boundary_host_static" "redis" {
  type            = "static"
  name            = "redis"
  description     = "redis container"
  address         = "redis.svc"
  host_catalog_id = boundary_host_catalog_static.databases.id
}

resource "boundary_host_static" "postgres" {
  type            = "static"
  name            = "postgres"
  description     = "postgres container"
  address         = "postgres.svc"
  host_catalog_id = boundary_host_catalog_static.databases.id
}
