
# Get your current IP address to provide access to Key Vault in the network acls
data "http" "my_ip" {
  url = "http://ifconfig.me"
}

# Create key vault and access policies
resource "azurerm_key_vault" "boundary" {
  name                       = local.vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.boundary.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment     = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  # Only allow access to the Key Vault from your public IP address and the controller and 
  # worker subnets. Also, allows access from Azure Services, which you could probably remove.
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["${data.http.my_ip.body}/32"]
    virtual_network_subnet_ids = [module.vnet.vnet_subnets[0], module.vnet.vnet_subnets[1]]

  }

}

# Access policy for controller VMs
# Uses the Controller user assigned identity
# This could probably be turned into a count loop or for_each with the worker policy
resource "azurerm_key_vault_access_policy" "controller" {
  key_vault_id = azurerm_key_vault.boundary.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.controller.principal_id

  key_permissions = [
    "get", "list", "update", "create", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign",
  ]

  secret_permissions = [
    "get", "list",
  ]

  certificate_permissions = [
    "get", "list",
  ]
}

# Access policy for worker VMs
# Uses the Worker user assigned identity
resource "azurerm_key_vault_access_policy" "worker" {
  key_vault_id = azurerm_key_vault.boundary.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.worker.principal_id

  key_permissions = [
    "get", "list", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign",
  ]

  secret_permissions = [
    "get", "list",
  ]

  certificate_permissions = [
    "get", "list",
  ]
}

# Access policy allowing your credentials full access to Key Vault
resource "azurerm_key_vault_access_policy" "you" {
  key_vault_id = azurerm_key_vault.boundary.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get", "list", "update", "create", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign", "delete", "purge",
  ]

  secret_permissions = [
    "get", "list", "set", "delete", "purge",
  ]

  certificate_permissions = [
    "get", "list", "create", "import", "delete", "update", "purge",
  ]
}

# Access policy for the generated service principal in azuread.tf
# Used to allow access to the recovery key for initial Boundary setup
resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.boundary.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_service_principal.recovery_sp.id

  key_permissions = [
    "get", "list", "wrapKey",
  ]
}

# Create three keys for root, recovery, and worker
resource "azurerm_key_vault_key" "keys" {
  depends_on   = [azurerm_key_vault_access_policy.you]
  for_each     = toset(["root", "worker", "recovery"])
  name         = each.key
  key_vault_id = azurerm_key_vault.boundary.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Create a self-signed certificate in Key Vault for workers and controllers
resource "azurerm_key_vault_certificate" "boundary" {
  depends_on   = [azurerm_key_vault_access_policy.you]
  name         = "boundary"
  key_vault_id = azurerm_key_vault.boundary.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2"]

      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = local.cert_san
      }

      subject            = "CN=${var.cert_cn}"
      validity_in_months = 12
    }
  }
}

