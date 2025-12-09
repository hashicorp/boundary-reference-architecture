# Copyright IBM Corp. 2020, 2023
# SPDX-License-Identifier: MPL-2.0

variable "url" {
  default = "http://127.0.0.1:9200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "randy",
    "susmitha",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "jeff",
    "pete",
    "jonathan",
    "malnick"
  ]
}

variable "target_ips" {
  type    = set(string)
  default = []
}

variable "tenant_id" {}

variable "vault_name" {}

variable "client_secret" {}

variable "client_id" {}
