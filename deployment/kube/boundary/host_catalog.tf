# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "boundary_host_catalog_static" "databases" {
  name        = "databases"
  description = "Database targets"
  scope_id = boundary_scope.project.id
}
