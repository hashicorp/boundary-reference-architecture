disable_mlock = true

telemetry { 
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

controller {
  name        = "demo-controller-${name_suffix}"
  description = "A controller for a demo!"

  database {
    url = "postgresql://boundary:boundarydemo@${db_endpoint}/boundary"
  }
}

listener "tcp" {
  address                           = "${private_ip}:9200"
	purpose                           = "api"
%{ if var.tls_disable == "true" }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "/etc/pki/tls/boundary/boundary.cert"  
  tls_key_file  = "/etc/pki/tls/boundary/boundary.key"
%{ endif }
	# proxy_protocol_behavior         = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
	cors_enabled                      = true
	cors_allowed_origins              = ["*"]
}

listener "tcp" {
  address                           = "${private_ip}:9201"
	purpose                           = "cluster"
%{ if var.tls_disable == "true" }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "/etc/pki/tls/boundary/boundary.cert"  
  tls_key_file  = "/etc/pki/tls/boundary/boundary.key"
%{ endif }
	# proxy_protocol_behavior         = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
}

kms "aead" {
	purpose   = "root"
	aead_type = "aes-gcm"
	key       = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
	key_id    = "global_root"
}

kms "aead" {
	purpose   = "worker-auth"
	aead_type = "aes-gcm"
	key       = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id    = "global_worker-auth"
}

kms "aead" {
	purpose   = "recovery"
	aead_type = "aes-gcm"
	key       = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id    = "global_recovery"
}
