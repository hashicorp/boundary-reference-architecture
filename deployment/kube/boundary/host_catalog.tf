resource "boundary_host_catalog_static" "databases" {
  name        = "databases"
  description = "Database targets"
  scope_id = boundary_scope.project.id
}
