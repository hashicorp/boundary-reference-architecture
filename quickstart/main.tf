terraform {
  required_providers {
    boundary = {
      source = "hashicorp/boundary"
      version = "1.1.4"
    }
  }
}

provider "boundary" {
  addr   = "https://xxxx.boundary.hashicorp.cloud"   # Replace with cluster URL
  auth_method_id                  = "ampw_xxxxxxx"   # Replace with auth method ID
  password_auth_method_login_name = "admin"          # Replace with login name 
  password_auth_method_password   = "password"       # Replace with password
}

# Org Scope
resource "boundary_scope" "MyOrg" {
  scope_id                 = "global"
  name                     = "MyOrgName"
  auto_create_admin_role   = true
}

# Project Scope
resource "boundary_scope" "MyProject" {
  scope_id                 = boundary_scope.MyOrg.id
  name                     = "MyProjectName"
  auto_create_admin_role   = true
}

# Target
resource "boundary_target" "MyTarget" {
  scope_id                 = boundary_scope.MyProject.id
  name                     = "MyTargetName"
  type                     = "tcp"
  address                  = "127.0.0.1"            # Replace with address
  default_port             = "22"                   # Replace with port
}

