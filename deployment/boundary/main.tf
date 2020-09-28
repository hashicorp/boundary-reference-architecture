terraform {
  required_providers {
    boundary = {
      source  = "localhost/providers/boundary"
      version = "0.0.1"
    }
  }
}

provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "aead" {
	purpose = "recovery"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_recovery"
}
EOT
}
