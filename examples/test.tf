module "aws" {
  source = "./aws"
}

module "boundary" {
  source             = "./boundary"
  url                = "http://${module.aws.boundary_lb}:9200"
  backend_server_ips = module.aws.backend_server_ips
}
