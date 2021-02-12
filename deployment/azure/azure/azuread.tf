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

resource "azuread_service_principal_password" "recovery_sp" {
  service_principal_id = azuread_service_principal.recovery_sp.id
  value                = random_password.recovery_sp.result
  end_date_relative    = "1h"
}