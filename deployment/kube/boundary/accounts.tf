resource "boundary_account" "user" {
  for_each       = var.users
  name           = "mark"
  description    = "User account for mark"
  type           = "password"
  login_name     = "mark"
  password       = "changeme"
  auth_method_id = boundary_auth_method.password.id
}
