resource "boundary_auth_method" "password" {
  name        = "org_password_auth"
  description = "Password auth method for org"
  type        = "password"
  scope_id    = boundary_scope.org.id
}
