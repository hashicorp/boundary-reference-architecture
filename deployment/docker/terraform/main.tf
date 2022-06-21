terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.0.9"
    }
  }
}

provider "boundary" {
  addr             = "http://127.0.0.1:9200"
  recovery_kms_hcl = <<EOT
kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_recovery"
}
EOT
}

variable "users" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
    "randy",
    "susmitha",
    "jeff",
    "pete",
    "harold",
    "patrick",
    "jonathan",
    "yoko",
    "brandon",
    "kyle",
    "justin",
    "melissa",
    "paul",
    "mitchell",
    "armon",
    "andy",
    "ben",
    "kristopher",
    "kris",
    "chris",
    "swarna",
    "mark",
    "julia",
  ]
}

resource "boundary_scope" "global" {
  global_scope = true
  name         = "global"
  scope_id     = "global"
}

resource "boundary_scope" "org" {
  scope_id    = boundary_scope.global.id
  name        = "primary"
  description = "Primary organization scope"
}

resource "boundary_scope" "proj_phoenix" {
  name                     = "phoenix"
  description              = "Phoenix Project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "ssh" {
  name                     = "ssh"
  description              = "SSH project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_user" "user" {
  for_each    = var.users
  name        = lower(each.key)
  description = "User resource for ${each.key}"
  account_ids = [boundary_account_password.user[each.value].id]
  scope_id    = boundary_scope.org.id
}

# resource "boundary_auth_method" "password" {
#   name        = "org_password_auth"
#   description = "Password auth method for org"
#   type        = "password"
#   scope_id    = boundary_scope.org.id
# }

# https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/auth_method
resource "boundary_auth_method" "password" {
  scope_id = boundary_scope.org.id
  type     = "password"
}


# resource "bondary_account_password" "user" {
#   for_each       = var.users
#   name           = each.key
#   description    = "User account for ${each.key}"
#   type           = "password"
#   login_name     = lower(each.key)
#   password       = "foofoofoo"
#   auth_method_id = boundary_auth_method.password.id
# }

# https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/account_password
resource "boundary_account_password" "user" {
  for_each       = var.users
  name           = lower(each.key)
  description    = "Account password for ${each.key}"
  auth_method_id = boundary_auth_method.password.id
  type           = "password"
  login_name     = lower(each.key)
  password       = "foofoofoo"
}



resource "boundary_role" "global_anon_listing" {
  scope_id = boundary_scope.global.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}

resource "boundary_role" "org_anon_listing" {
  scope_id = boundary_scope.org.id
  grant_strings = [
    "id=*;type=auth-method;actions=list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password"
  ]
  principal_ids = ["u_anon"]
}
resource "boundary_role" "org_admin" {
  scope_id       = "global"
  grant_scope_id = boundary_scope.org.id
  grant_strings  = ["id=*;type=*;actions=*"]
  principal_ids = concat(
    [for user in boundary_user.user : user.id],
    ["u_auth"]
  )
}

resource "boundary_role" "proj_admin" {
  scope_id       = boundary_scope.org.id
  grant_scope_id = boundary_scope.proj_phoenix.id
  grant_strings  = ["id=*;type=*;actions=*"]
  principal_ids = concat(
    [for user in boundary_user.user : user.id],
    ["u_auth"]
  )
}

# resource "boundary_host_catalog_static" "proj_phoenix" {
#   name        = "proj_phoenix"
#   description = "Database targets"
#   type        = "static"
#   scope_id    = boundary_scope.proj_phoenix.id
# }

# resource "boundary_host_catalog_static" "localhost" {
#   type            = "static"
#   name            = "localhost"
#   description     = "Localhost host"
#   address         = "localhost"
#   host_catalog_id = boundary_host_catalog_static.project.id
# }

# https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/host_catalog
resource "boundary_host_catalog_static" "proj_phoenix" {
  name        = "proj_phoenix"
  description = "Database targets"
  scope_id    = boundary_scope.proj_phoenix.id
}

# https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/host
resource "boundary_host_catalog_static" "localhost" {
  name        = "localhost"
  description = "Localhost host"
  scope_id    = boundary_scope.proj_phoenix.id
}

# Target hosts available on localhost: ssh and postgres
# Postgres is exposed to localhost for debugging of the 
# Boundary DB from the CLI. Assumes SSHD is running on
# localhost.
resource "boundary_host_set_static" "local" {
  type            = "static"
  name            = "local"
  description     = "Host set for local servers"
  host_catalog_id = boundary_host_catalog_static.localhost.id
}

resource "boundary_target" "ssh" {
  type                     = "tcp"
  name                     = "ssh"
  description              = "SSH server"
  scope_id                 = boundary_scope.proj_phoenix.id
  session_connection_limit = -1
  session_max_seconds      = 2
  default_port             = 22
  # host_set_ids = [
  #   boundary_host_set_static.local.id
  # ]
}

resource "boundary_target" "postgres" {
  type                     = "tcp"
  name                     = "postgres"
  description              = "Postgres server"
  scope_id                 = boundary_scope.proj_phoenix.id
  session_connection_limit = -1
  session_max_seconds      = 2
  default_port             = 5432
  # host_set_ids = [
  #   boundary_host_set_static.local.id
  # ]
}

resource "boundary_host_catalog_static" "cassandra" {
  name        = "cassandra"
  description = "Private cassandra container"
  scope_id    = boundary_scope.proj_phoenix.id
}

resource "boundary_host_set_static" "cassandra" {
  type            = "static"
  name            = "cassandra"
  description     = "Host set for cassandra containers"
  host_catalog_id = boundary_host_catalog_static.cassandra.id
}

resource "boundary_target" "cassandra" {
  type                     = "tcp"
  name                     = "cassandra"
  description              = "Cassandra server"
  scope_id                 = boundary_scope.proj_phoenix.id
  session_connection_limit = -1
  session_max_seconds      = 2
  default_port             = 7000
  # host_set_ids = [
  #   boundary_host_set_static.cassandra.id
  # ]
}

resource "boundary_host_catalog_static" "mysql" {
  name        = "mysql"
  description = "Private mysql container"
  scope_id    = boundary_scope.proj_phoenix.id
}

# resource "boundary_host_set_static" "mysql" {
#   type            = "static"
#   name            = "mysql"
#   description     = "Host set for mysql containers"
#   host_catalog_id = boundary_host_catalog_static.mysql.id
#   # host_ids        = [boundary_host_catalog_static.mysql.id]
# }

resource "boundary_target" "mysql" {
  type                     = "tcp"
  name                     = "mysql"
  description              = "MySQL server"
  scope_id                 = boundary_scope.proj_phoenix.id
  session_connection_limit = -1
  session_max_seconds      = 2
  default_port             = 3306
  # host_set_ids = [
  #   boundary_host_set_static.mysql.id
  # ]
}

resource "boundary_host_catalog_static" "redis" {
  name        = "redis"
  description = "Private redis container"
  scope_id    = boundary_scope.proj_phoenix.id
}

# resource "boundary_host_set_static" "redis" {
#   type            = "static"
#   name            = "redis"
#   description     = "Host set for redis containers"
#   host_catalog_id = boundary_host_catalog_static.redis.id
#   # host_ids        = [boundary_host_catalog_static.redis.id] 
# }

resource "boundary_target" "redis" {
  type                     = "tcp"
  name                     = "redis"
  description              = "Redis server"
  scope_id                 = boundary_scope.proj_phoenix.id
  session_connection_limit = -1
  session_max_seconds      = 2
  default_port             = 6379
  # host_set_ids = [
  #   boundary_host_set_static.redis.id
  # ]
}

resource "boundary_target" "mssql" {
  type                     = "tcp"
  name                     = "mssql"
  description              = "Microsoft SQL server"
  scope_id                 = boundary_scope.proj_phoenix.id
  session_connection_limit = -1
  session_max_seconds      = 2
  default_port             = 1433
  # host_set_ids = [
  #   boundary_host_set_static.local.id
  # ]
}
