# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "~>1.0"
    }
  }
}

provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "azurekeyvault" {
    purpose = "recovery"
	tenant_id     = "${var.tenant_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
    vault_name = "${var.vault_name}"
    key_name = "recovery"
}
EOT
}