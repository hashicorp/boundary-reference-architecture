variable "boundary_addr" {
  default = "http://127.0.0.1:9200"
}

module "kubernetes" {
  source = "./kubernetes"
}

module "boundary" {
  source = "./boundary"
  addr   = var.boundary_addr
}
