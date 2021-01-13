resource "boundary_host" "redis" {
  type        = "static"
  name        = "redis"
  description = "redis container"
  // using domain name from the kube service
  address         = "redis"
  host_catalog_id = boundary_host_catalog.databases.id
}

resource "boundary_host" "postgres" {
  type        = "static"
  name        = "postgres"
  description = "postgres container"
  // using the domain name from the kube service
  address         = "postgres"
  host_catalog_id = boundary_host_catalog.databases.id
}

resource "boundary_host" "localhost" {
  type            = "static"
  name            = "localhost"
  description     = "127.0.0.1"
  address         = "localhost"
  host_catalog_id = boundary_host_catalog.databases.id
}
