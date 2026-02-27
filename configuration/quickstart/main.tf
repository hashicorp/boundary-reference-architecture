# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This Terraform script for HCP/OSS Boundary sets up the basic Org, Project, and Target. 
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

# Target setup, which belongs to the MyProject scope
resource "boundary_target" "MyTarget" {
  scope_id                 = boundary_scope.MyProject.id
  name                     = "MyTargetName"
  type                     = "tcp"
  address                  = "127.0.0.1"            # Replace with address
  default_port             = "22"                   # Replace with port
}

