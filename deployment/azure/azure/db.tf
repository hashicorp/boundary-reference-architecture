# Create postgresql server

# You need to use a GP size or better to support the virtual
# Network rules. Basic version of Azure Postgres doesn't support it
resource "azurerm_postgresql_server" "boundary" {
  name                = local.pg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name

  administrator_login          = var.db_username
  administrator_login_password = var.db_password

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 51200

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

}

#Lock down access to only the controller subnet
resource "azurerm_postgresql_virtual_network_rule" "vnet" {
  name                = "postgresql-vnet-rule"
  resource_group_name = azurerm_resource_group.boundary.name
  server_name         = azurerm_postgresql_server.boundary.name
  subnet_id           = module.vnet.vnet_subnets[0]

  # Setting this to true for now, probably not necessary
  ignore_missing_vnet_service_endpoint = true
}
