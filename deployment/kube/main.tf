module "kubernetes" {
  source = "./kubernetes"
}

module "boundary" {
  source = "./boundary"
  url    = "http://${module.kubernetes.boundary_ip}:9200"
}
