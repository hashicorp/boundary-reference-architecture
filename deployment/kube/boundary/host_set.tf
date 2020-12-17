resource "boundary_host_set" "redis_containers" {
  type            = "static"
  name            = "redis_containers"
  description     = "Host set for redis containers"
  host_catalog_id = boundary_host_catalog.databases.id
  host_ids        = [boundary_host.redis.id]
}

resource "boundary_host_set" "postgres_containers" {
  type            = "static"
  name            = "postgres_containers"
  description     = "Host set for postgres containers"
  host_catalog_id = boundary_host_catalog.databases.id
  host_ids        = [boundary_host.postgres.id]
}
