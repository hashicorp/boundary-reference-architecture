resource "boundary_auth_method_password" "password" {
  name        = "org_password_auth"
  description = "Password auth method for org"
  scope_id    = boundary_scope.org.id
}
