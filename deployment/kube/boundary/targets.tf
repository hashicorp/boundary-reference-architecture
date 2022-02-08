resource "boundary_target" "redis" {
  type                     = "tcp"
  name                     = "redis"
  description              = "Redis container"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  session_max_seconds      = 10000
  default_port             = 6379
  #   host_ids = [
  #   boundary_host.foo.id,
  #   boundary_host.bar.id,
  # ]
  # host_source_ids = [
  #   boundary_host_set_static.redis_containers.id
  # ]
}


# resource "boundary_target" "redis" {
#   name                     = "redis"
#   description  = "Foo target"
#   type         = "tcp"
#   default_port = "6379"
#   scope_id     = boundary_scope.project.id
#   host_source_ids = [
#     boundary_host_set_static.redis_containers.id
#   ]
#   # application_credential_source_ids = [
#   #   boundary_credential_library_vault.foo.id
#   # ]
# }

# resource "boundary_target" "postgres" {
#   type                     = "tcp"
#   name                     = "postgres"
#   description              = "Postgres server"
#   scope_id                 = boundary_scope.project.id
#   session_connection_limit = -1
#   session_max_seconds      = 10000
#   default_port             = 5432
#   host_source_ids = [
#     boundary_host_set_static.postgres_containers.id
#   ]
# }


