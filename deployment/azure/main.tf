variable "boundary_version" {
  type    = string
  default = "0.5.1"
}

module "azure" {
  source              = "./azure"
  controller_vm_count = 1
  worker_vm_count     = 1
  boundary_version    = var.boundary_version
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

output "vault_name" {
  value = module.azure.vault_name
}

output "boundary_address" {
  value = "https://${module.azure.public_dns_name}:9200"
}

output "auth_method_id" {
  value = module.boundary.auth_method_id
}

output "ssh_target_id" {
  value = module.boundary.ssh_target_id
}