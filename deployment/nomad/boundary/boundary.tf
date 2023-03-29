terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.0.7"
    }
  }
}

provider "boundary" {
  addr             = var.boundary_address
  recovery_kms_hcl = <<EOT
kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_recovery"
}
EOT
}
