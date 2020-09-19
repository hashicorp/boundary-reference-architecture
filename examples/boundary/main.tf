terraform {
  required_providers {
    boundary = {
      source  = "localhost/providers/boundary"
      version = "0.0.1"
    }
  }
}

provider "boundary" {
  addr                            = var.url
  auth_method_id                  = "ampw_0000000000"
  password_auth_method_login_name = "foo"
  password_auth_method_password   = "foofoofoo"
}


resource "boundary_scope" "corp" {
  scope_id         = "global"
  auto_create_role = true
}

resource "boundary_user" "backend" {
  for_each    = var.backend_team
  name        = each.key
  description = "Backend user: ${each.key}"
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "frontend" {
  for_each    = var.frontend_team
  name        = each.key
  description = "Frontend user: ${each.key}"
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "leadership" {
  for_each    = var.leadership_team
  name        = each.key
  description = "WARNING: Managers should be read-only"
  scope_id    = boundary_scope.corp.id
}

// organiation level group for the leadership team
resource "boundary_group" "leadership" {
  name        = "leadership_team"
  description = "Organization group for leadership team"
  member_ids  = [for user in boundary_user.leadership : user.id]
  scope_id    = boundary_scope.corp.id
}

// add org-level role for readonly access
resource "boundary_role" "organization_readonly" {
  name          = "readonly"
  description   = "Read-only role"
  principal_ids = [boundary_group.leadership.id]
  grant_strings = ["id=*;actions=read"]
  scope_id      = boundary_scope.corp.id
}

// add org-level role for administration access
resource "boundary_role" "organization_admin" {
  name        = "admin"
  description = "Administrator role"
  principal_ids = concat(
    [for user in boundary_user.backend : user.id],
    [for user in boundary_user.frontend : user.id]
  )
  grant_strings = ["id=*;actions=create,read,update,delete"]
  scope_id      = boundary_scope.corp.id
}

// create a project for core infrastructure
resource "boundary_scope" "core_infra" {
  description      = "Core infrastrcture"
  scope_id         = boundary_scope.corp.id
  auto_create_role = true
}

// add org-level role for administration access
resource "boundary_role" "project_admin" {
  name        = "core_infra_admin"
  description = "Administrator role for core infra"
  principal_ids = concat(
    [for user in boundary_user.backend : user.id],
    [for user in boundary_user.frontend : user.id]
  )
  grant_strings = ["id=*;actions=create,read,update,delete"]
  scope_id      = boundary_scope.core_infra.id
}

resource "boundary_group" "backend_core_infra" {
  name        = "backend"
  description = "Backend team group"
  member_ids  = [for user in boundary_user.backend : user.id]
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_group" "frontend_core_infra" {
  name        = "frontend"
  description = "Frontend team group"
  member_ids  = [for user in boundary_user.frontend : user.id]
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "backend_servers_ssh" {
  for_each        = var.backend_server_ips
  type            = "static"
  name            = "backend_server_ssh_${each.value}"
  description     = "Backend server host for SSH port"
  address         = "${each.key}:22"
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host_catalog" "backend_servers" {
  name        = "backend_servers"
  description = "Web servers for backend team"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host_set" "backend_servers_service" {
  type            = "static"
  name            = "backend_servers_service"
  description     = "Host set for services servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.backend_servers_service : host.id]
}

resource "boundary_host_set" "backend_servers_ssh" {
  type            = "static"
  name            = "backend_servers_ssh"
  description     = "Host set for backend servers SSH access"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.backend_servers_ssh : host.id]
}

resource "boundary_target" "backend_servers_ssh" {
  type        = "tcp"
  name        = "backend_servers_ssh"
  description = "Backend SSH target"
  scope_id    = boundary_scope.core_infra.id

  host_set_ids = [
    boundary_host_set.backend_servers_ssh.id
  ]
}
