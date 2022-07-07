resource "boundary_user" "admin_user" {
  name        = "admin"
  account_ids = [boundary_account_password.admin_acct.id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_account_password" "admin_acct" {
  name           = "admin"
  type           = "password"
  login_name     = "admin"
  password       = "foofoofoo"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_group" "backend_core_infra" {
  name        = "backend"
  description = "Backend team group"
  member_ids  = [boundary_user.admin_user.id]
  scope_id    = boundary_scope.core_infra.id
}
