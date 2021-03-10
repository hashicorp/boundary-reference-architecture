# The reference architecture creates a new Vnet
# You might not want a new Vnet. Too bad.
variable "location" {
  type    = string
  default = "eastus"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

variable "subnet_names" {
  type = list(string)
  default = [
    "controllers",
    "workers",
    "backend",
  ]
}

# This seems like a reasonable size, feel free to change
variable "controller_vm_size" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "controller_vm_count" {
  type    = number
  default = 1
}

variable "worker_vm_size" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "backend_vm_count" {
  type    = number
  default = 1
}

variable "backend_vm_size" {
  type    = string
  default = "Standard_D2as_v4"
}

variable "worker_vm_count" {
  type    = number
  default = 1
}

variable "db_username" {
  type    = string
  default = "sqladmin"
}

variable "db_password" {
  type    = string
  default = "B0un4aryPGAdm!n"
}

variable "cert_cn" {
  type    = string
  default = "boundary-azure"
}

variable "boundary_version" {
  type    = string
  default = "0.1.8"
}

resource "random_id" "id" {
  byte_length = 4
}

locals {
  resource_group_name = "boundary-${random_id.id.hex}"

  controller_net_nsg = "controller-net-${random_id.id.hex}"
  worker_net_nsg     = "worker-net-${random_id.id.hex}"
  backend_net_nsg    = "backend-net-${random_id.id.hex}"

  controller_nic_nsg = "controller-nic-${random_id.id.hex}"
  worker_nic_nsg     = "worker-nic-${random_id.id.hex}"
  backend_nic_nsg    = "backend-nic-${random_id.id.hex}"

  controller_asg = "controller-asg-${random_id.id.hex}"
  worker_asg     = "worker-asg-${random_id.id.hex}"
  backend_asg    = "backend-asg-${random_id.id.hex}"

  controller_vm = "controller-${random_id.id.hex}"
  worker_vm     = "worker-${random_id.id.hex}"
  backend_vm    = "backend-${random_id.id.hex}"

  controller_user_id = "controller-userid-${random_id.id.hex}"
  worker_user_id     = "worker-userid-${random_id.id.hex}"

  pip_name = "boundary-${random_id.id.hex}"
  lb_name  = "boundary-${random_id.id.hex}"

  vault_name = "boundary-${random_id.id.hex}"

  pg_name = "boundary-${random_id.id.hex}"

  sp_name = "boundary-${random_id.id.hex}"

  cert_san = ["boundary-${random_id.id.hex}.${var.location}.cloudapp.azure.com"]

}
