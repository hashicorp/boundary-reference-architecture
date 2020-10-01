resource "random_pet" "test" {
  length = 1
}

locals {
  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

variable "tag" {
  default = "boundary-test"
}

variable "boundary_bin" {
  default = "~/projects/boundary/bin"
}

variable "pub_ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "num_workers" {
  default = 1
}

variable "num_controllers" {
  default = 1
}

variable "num_targets" {
  default = 1
}
