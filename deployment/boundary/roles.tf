resource "boundary_role" "org_admin" {
  scope_id       = boundary_scope.global.id
  grant_scope_id = boundary_scope.org.id
  grant_strings  = ["id=*;actions=*;type=*"]
  principal_ids = concat(
    [for user in boundary_user.backend : user.id],
    [for user in boundary_user.frontend : user.id],
  ["u_auth"])
}

resource "boundary_role" "org_anon_listing" {
  scope_id      = boundary_scope.org.id
  grant_strings = ["id=*;type=auth-method;actions=list,authenticate"]
  principal_ids = ["u_anon"]
}

resource "boundary_role" "global_anon" {
  scope_id = boundary_scope.global.id
  grant_strings = ["id=*;type=scope;actions=list,read", "id=*;type=auth-method;actions=read,list"]
  principal_ids = ["u_anon"]
}

// add org-level role for readonly access
resource "boundary_role" "organization_readonly" {
  name          = "readonly"
  description   = "Read-only role"
  principal_ids = [boundary_group.leadership.id]
  grant_strings = ["id=*;type=*;actions=read"]
  scope_id      = boundary_scope.org.id
}

// add org-level role for administration access
resource "boundary_role" "project_admin" {
  name           = "core_infra_admin"
  description    = "Administrator role for core infra"
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.core_infra.id
  principal_ids  = ["u_auth"]
  grant_strings  = ["id=*;type=*;actions=*"]
}
