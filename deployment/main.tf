module "aws" {
  source = "./aws"
}

module "boundary" {
  source              = "./boundary"
  url                 = "http://${module.aws.boundary_lb}:9200"
  target_ips          = module.aws.target_ips
  kms_recovery_key_id = module.aws.kms_recovery_key_id
}
