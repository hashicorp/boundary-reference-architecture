resource "tls_private_key" "boundary" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "boundary" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.boundary.private_key_pem

  subject {
    common_name  = "boundary.dev"
    organization = "Boundary, dev."
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.boundary.private_key_pem
  certificate_body = tls_self_signed_cert.boundary.cert_pem

  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}
