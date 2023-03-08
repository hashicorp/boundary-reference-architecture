resource "boundary_scope" "DadgarCorp" {
  name                     = "DadgarCorp"
  scope_id                 = "global"
  auto_create_admin_role   = true
}

resource "boundary_scope" "Boundary-Insiders-Infra" {
  name                     = "Boundary-Insiders-Infra"
  scope_id                 = boundary_scope.DadgarCorp.id
  auto_create_admin_role   = true
}
