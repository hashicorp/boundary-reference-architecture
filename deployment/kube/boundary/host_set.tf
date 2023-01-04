# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "boundary_host_set_static" "redis_containers" {
  type            = "static"
  name            = "redis_containers"
  description     = "Host set for redis containers"
  host_catalog_id = boundary_host_catalog_static.databases.id
  host_ids        = [boundary_host_static.redis.id]
}

resource "boundary_host_set_static" "postgres_containers" {
  type            = "static"
  name            = "postgres_containers"
  description     = "Host set for postgres containers"
  host_catalog_id = boundary_host_catalog_static.databases.id
  host_ids        = [boundary_host_static.postgres.id]
}
