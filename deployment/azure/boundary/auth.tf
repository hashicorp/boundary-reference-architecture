# Copyright IBM Corp. 2020, 2023
# SPDX-License-Identifier: MPL-2.0

resource "boundary_auth_method_password" "password" {
  name        = "corp_password_auth_method"
  description = "Password auth method for Corp org"
  scope_id    = boundary_scope.org.id
}

output "auth_method_id" {
  value = boundary_auth_method_password.password.id
}