# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "google_kms_key_ring" "this" {
  name     = local.boundary_name
  location = "global"
}

resource "google_kms_crypto_key" "root" {
  name            = local.boundary_root_key_name
  key_ring        = google_kms_key_ring.this.id
  rotation_period = var.kms_crypto_key_rotation_period
}

resource "google_kms_crypto_key" "worker_auth" {
  name            = local.boundary_worker_auth_key_name
  key_ring        = google_kms_key_ring.this.id
  rotation_period = var.kms_crypto_key_rotation_period
}

resource "google_kms_crypto_key" "recovery" {
  name            = local.boundary_recovery_key_name
  key_ring        = google_kms_key_ring.this.id
  rotation_period = var.kms_crypto_key_rotation_period
}

