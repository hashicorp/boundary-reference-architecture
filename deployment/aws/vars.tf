# Copyright (c) HashiCorp, Inc.
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
