# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

### Service Account creation for Google Compute Instances
resource "random_string" "boundary_controller" {
  upper   = false
  special = false
  numeric = false
  length  = 16
}

resource "random_string" "boundary_worker" {
  upper   = false
  special = false
  numeric = false
  length  = 16
}

resource "google_service_account" "boundary_controller" {
  account_id   = random_string.boundary_controller.result
  display_name = local.boundary_controller_name
}


resource "google_service_account" "boundary_worker" {
  account_id   = random_string.boundary_worker.result
  display_name = local.boundary_worker_name
}


### IAM for KMS access
data "google_iam_policy" "kms" {
  binding {
    role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

    members = [
      "serviceAccount:${google_service_account.boundary_controller.email}",
      "serviceAccount:${google_service_account.boundary_worker.email}"
    ]
  }
  binding {
    role = "roles/cloudkms.viewer"

    members = [
      "serviceAccount:${google_service_account.boundary_controller.email}",
      "serviceAccount:${google_service_account.boundary_worker.email}"
    ]
  }

}

resource "google_kms_crypto_key_iam_policy" "root" {
  crypto_key_id = google_kms_crypto_key.root.id
  policy_data   = data.google_iam_policy.kms.policy_data
}

resource "google_kms_crypto_key_iam_policy" "worker_auth" {
  crypto_key_id = google_kms_crypto_key.worker_auth.id
  policy_data   = data.google_iam_policy.kms.policy_data
}

resource "google_kms_crypto_key_iam_policy" "recovery" {
  crypto_key_id = google_kms_crypto_key.recovery.id
  policy_data   = data.google_iam_policy.kms.policy_data
}


### IAM policy for certificate generation
data "google_iam_policy" "cas" {
  count    = var.tls_disabled == true ? 0 : 1
  binding {
    role = "roles/privateca.certificateManager"
    members = [
      "serviceAccount:${google_service_account.boundary_controller.email}",
      "serviceAccount:${google_service_account.boundary_worker.email}"
    ]
  }
}


data "google_iam_policy" "admin" {
  binding {
    role = "roles/privateca.certificateManager"
    members = [
      "serviceAccount:${google_service_account.boundary_controller.email}",
      "serviceAccount:${google_service_account.boundary_worker.email}"
    ]
  }
}

resource "google_privateca_ca_pool_iam_policy" "policy" {
  ca_pool = google_privateca_ca_pool.default.id
  policy_data = data.google_iam_policy.admin.policy_data
}
