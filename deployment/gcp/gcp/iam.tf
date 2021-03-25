### Service Account creation for Google Compute Instances
resource "random_string" "boundary_controller" {
  upper   = false
  special = false
  number  = false
  length  = 16
}

resource "random_string" "boundary_worker" {
  upper   = false
  special = false
  number  = false
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
  provider = google-beta
  binding {
    role = "roles/privateca.certificateManager"
    members = [
      "serviceAccount:${google_service_account.boundary_controller.email}",
      "serviceAccount:${google_service_account.boundary_worker.email}"
    ]
  }
}

resource "google_privateca_certificate_authority_iam_policy" "cas" {
  provider              = google-beta
  certificate_authority = google_privateca_certificate_authority.this.id
  policy_data           = data.google_iam_policy.cas.policy_data
}

### IAM for logging
data "google_iam_policy" "logging" {
  provider = google-beta
  binding {
    role = "roles/stackdriver.resourceMetadata.writer"
    members = [
      "serviceAccount:${google_service_account.boundary_controller.email}",
      "serviceAccount:${google_service_account.boundary_worker.email}"
    ]
  }
}

# resource "google_compute_instance_iam_policy" "controller_logging" {
#   instance_name = google_compute_instance_template.controller.name
#   policy_data = data.google_iam_policy.logging.policy_data
# }

# resource "google_compute_instance_iam_policy" "worker_logging" {
#   instance_name = google_compute_instance_template.worker.name
#   policy_data = data.google_iam_policy.logging.policy_data
# }



