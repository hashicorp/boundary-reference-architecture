module "azure" {
  source              = "./azure"
  controller_vm_count = 1
  worker_vm_count     = 1
}

module "boundary" {
  source        = "./boundary"
  url           = module.azure.url
  target_ips    = module.azure.target_ips
  tenant_id     = module.azure.tenant_id
  client_id     = module.azure.client_id
  client_secret = module.azure.client_secret
  vault_name    = module.azure.vault_name
}
