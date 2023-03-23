# This Terraform script for HCP/OSS Boundary sets up a new fully-privileged user with a new password auth method.
# A user must be associated with an account, which belongs to an auth method. For a user to have full permissions
# at each scope level, the user must be added to a role in each scope. 
#
# Prerequisites: The Boundary cluster must be deployed.
# Note: This script is only for learning purposes and is not recommended for a production deployment

terraform {
  required_providers {
    boundary = {
      source = "hashicorp/boundary"
      version = "1.1.4"
    }
  }
}

# Boundary cluster information
provider "boundary" {
  addr   = "https://xxxx.boundary.hashicorp.cloud"   # Replace with cluster URL
  auth_method_id                  = "ampw_xxxxxxx"   # Replace with auth method ID
  password_auth_method_login_name = "admin"          # Replace with login name 
  password_auth_method_password   = "password"       # Replace with password
}

# Org scope setup, which belongs to the global scope
resource "boundary_scope" "MyOrg" {
  scope_id                 = "global"
  name                     = "MyOrgName"
  auto_create_admin_role   = true
}

# Project scope setup, which belongs to the MyOrg scope
resource "boundary_scope" "MyProject" {
  scope_id                 = boundary_scope.MyOrg.id
  name                     = "MyProjectName"
  auto_create_admin_role   = true
}


#======================================================================================
# User Setup
#======================================================================================

# Auth Method setup in the global scope
resource "boundary_auth_method" "MyAuthMethod" {
  scope_id = "global"
  name     = "MyAuthMethodName"
  type     = "password"
}

# Account setup with MyAuthMethod
resource "boundary_account_password" "MyAccount" {
  auth_method_id = boundary_auth_method.MyAuthMethod.id
  type           = "password"
  name           = "MyAccountName"
  login_name     = "myadmin"             # Replace with desired login name
  password       = "password"            # Replace with desired password
}

# User setup with MyAccount in the global scope
resource "boundary_user" "MyUser" {
  name        = "MyUserName"
  account_ids = [boundary_account_password.MyAccount.id]
  scope_id    = "global"
}

# Global role creation with MyUser as the principal
# Principals in this role have full permissions to Global
resource "boundary_role" "MyGlobalRole" {
  name          = "MyGlobalRoleName"
  principal_ids = [boundary_user.MyUser.id]
  scope_id      = "global"
  grant_strings = ["id=*;type=*;actions=*"]
}

# Org role creation with MyUser as the principal
# Principals in this role have full permissions to MyOrg
resource "boundary_role" "MyOrgRole" {
  name          = "MyOrgRoleName"
  principal_ids = [boundary_user.MyUser.id]
  scope_id      = boundary_scope.MyOrg.id
  grant_strings = ["id=*;type=*;actions=*"]
}

# Project role creation with MyUser as the principal
# Principals in this role have full permissions to Global
resource "boundary_role" "MyProjectRole" {
  name          = "MyProjectRoleName"
  principal_ids = [boundary_user.MyUser.id]
  scope_id      = boundary_scope.MyProject.id
  grant_strings = ["id=*;type=*;actions=*"]
}