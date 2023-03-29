variable "boundary_address" {
  default = "http://localhost:9200"
}

variable "nomad_address" {
  default = "http://localhost:4646"
}

variable "target_ips" {
  type = set(string)
  description = "SSH Targets for Boundary to proxy"
  default = ["127.0.0.1"]
}

module "nomad" {
  source        = "./nomad"
  nomad_address = var.nomad_address
}

module "boundary" {
  source           = "./boundary"
  boundary_address = var.boundary_address
  target_ips       = var.target_ips
}
