# We need to create an Azure AD service principal for use by Boundary
# to perform the initial configuraiton of Boundary with the recovery
# key in Azure Key Vault

data "azuread_client_config" "current" {}

resource "azuread_application" "recovery_sp" {
  display_name = local.sp_name
  owners = [data.azuread_client_config.current.object_id]
}

# This service principal is used to access the recovery key in Azure
# key vault. The recovery key is used to perform initial setup of 
# Boundary. After an authentication method has been enabled, you will
# no longer need a recovery key to access Boundary.
resource "azuread_service_principal" "recovery_sp" {
  application_id = azuread_application.recovery_sp.application_id
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "recovery_sp" {
  service_principal_id = azuread_service_principal.recovery_sp.id
}