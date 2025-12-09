# Copyright IBM Corp. 2020, 2023
# SPDX-License-Identifier: MPL-2.0

resource "boundary_auth_method_password" "password" {
  name        = "org_password_auth"
  description = "Password auth method for org"
  scope_id    = boundary_scope.org.id
}
