resource "boundary_host" "redis" {
  type            = "static"
  name            = "redis"
  description     = "redis container"
  address         = "redis.svc"
  host_catalog_id = boundary_host_catalog.databases.id
}

resource "boundary_host" "postgres" {
  type            = "static"
  name            = "postgres"
  description     = "postgres container"
  address         = "postgres.svc"
  host_catalog_id = boundary_host_catalog.databases.id
}
