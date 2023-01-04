# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.0.5"
    }
  }
}

provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "gcpckms" {
  purpose     = "recovery"
  key_ring    = "${var.key_ring}"
  crypto_key  = "${var.recovery_key}"
	project     = "${var.gcp_project}"
	region      = "global"
}
EOT
}
