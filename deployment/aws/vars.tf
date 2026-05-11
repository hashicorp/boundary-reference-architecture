# Copyright IBM Corp. 2020, 2026
# SPDX-License-Identifier: MPL-2.0

variable "boundary_bin" {
  default = "~/projects/boundary/bin"
}

variable "pub_ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "priv_ssh_key_path" {
  default = ""
}
