provider "google" {
  project = "go-gcp-demos"
  region  = "australia-southeast1"
}

module "gcp" {
  source       = "./gcp"
  enable_ssh   = true
  ssh_key_path = "/Users/grant/.ssh/id_rsa.pub"
  my_public_ip = "27.32.248.192/32"
}

