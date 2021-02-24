# We need to create an Azure AD service principal for use by Boundary
# to perform the initial configuraiton of Boundary with the recovery
# key in Azure Key Vault

provider "azuread" {}

data "azuread_client_config" "current" {}

resource "random_password" "recovery_sp" {
  length  = 16
  special = true
}

resource "azuread_application" "recovery_sp" {
  display_name = local.sp_name
}

resource "azuread_service_principal" "recovery_sp" {
  application_id = azuread_application.recovery_sp.application_id
}

# Password is set for 1h. The credentials will expire after that. 
# If you want to keep using Terraform with Boundary, you can
# create credentials in Boundary to do that instead of using the
# recovery key.

resource "azuread_service_principal_password" "recovery_sp" {
  service_principal_id = azuread_service_principal.recovery_sp.id
  value                = random_password.recovery_sp.result
  end_date_relative    = "1h"
}