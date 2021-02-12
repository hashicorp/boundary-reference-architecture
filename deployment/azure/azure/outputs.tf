output "vault_name" {
  value = local.vault_name
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "url" {
  value = "https://${azurerm_public_ip.boundary.fqdn}:9200"
}

output "target_ips" {
  value = ""
}

output "client_id" {
  value = azuread_service_principal.recovery_sp.application_id
}

output "client_secret" {
  value = random_password.recovery_sp.result
}