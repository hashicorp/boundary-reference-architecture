provider "google" {
  project = "go-gcp-demos"
  region  = "australia-southeast1"
}

module "gcp" {
  source       = "./gcp"
  enable_ssh   = false
  ssh_key_path = "/Users/grant/.ssh/id_rsa.pub"
}

# module "debugging_example" {
# 	module "gcp" {
#   source       = "./gcp"
#   enable_ssh   = true
#   ssh_key_path = "/Users/grant/.ssh/id_rsa.pub"
#   my_public_ip = "17.42.249.192/32"
# }

# module "custom_ports" {
# 	module "gcp" {
#   source       = "./gcp"
# 	controller_api_port = 9210
# 	controller_cluster_port = 9211
# 	worker_port = 9212
# }