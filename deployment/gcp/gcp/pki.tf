resource "google_privateca_certificate_authority" "this" {
  provider                 = google-beta
  location                 = var.ca_issuer_location
  project                  = var.project
  certificate_authority_id = local.boundary_name
  config {
    subject_config {
      subject {
        organization = var.ca_organization
      }
      common_name = var.ca_common_name
      dynamic "subject_alt_name" {
        for_each = var.ca_subject_alternate_names
        content {
          dns_names = each.value
        }
      }
    }
    reusable_config {
      reusable_config = "root-unconstrained"
    }
  }
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}

## Check iam.tf for IAM priveleges related to certificate generation