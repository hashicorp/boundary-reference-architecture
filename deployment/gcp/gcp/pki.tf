# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
resource "google_privateca_ca_pool" "default" {
  name = "boundary-ca-pool"
  location = var.ca_issuer_location
  tier = "ENTERPRISE"
  publishing_options {
    publish_ca_cert = true
    publish_crl = true
  }
  labels = {
    project = "boundary"
  }
}

data "google_privateca_ca_pool_iam_policy" "policy" {
  ca_pool = google_privateca_ca_pool.default.id
}

resource "google_privateca_certificate_authority" "this" {
  pool = google_privateca_ca_pool.default.name
  count                    = var.tls_disabled == true ? 0 : 1
  location                 = var.ca_issuer_location
  project                  = var.project
  certificate_authority_id = local.boundary_name
  config {
    subject_config {
      subject {
        organization = var.ca_organization
        common_name = var.ca_common_name
      }
      dynamic "subject_alt_name" {
        for_each = var.ca_subject_alternate_names
        content {
          dns_names = each.value
        }
      }
    }
    x509_config {
      ca_options {
        is_ca = true
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign = true
        }
        extended_key_usage {
          server_auth = false
        }
      }
    }
  }
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}

## Check iam.tf for IAM priveleges related to certificate generation
