module "aws" {
  source           = "./aws"
  boundary_bin     = var.boundary_bin
  pub_ssh_key_path = var.pub_ssh_key_path
  priv_ssh_key_path = var.priv_ssh_key_path
}

module "boundary" {
  source              = "./boundary"
  url                 = "http://${module.aws.boundary_lb}:9200"
  target_ips          = module.aws.target_ips
  kms_recovery_key_id = module.aws.kms_recovery_key_id
}
