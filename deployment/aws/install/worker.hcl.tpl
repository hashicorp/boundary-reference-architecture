listener "tcp" {
  address = "${private_ip}:9202"
	purpose = "proxy"
%{ if var.tls_disable == "true" }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "/etc/pki/tls/boundary/boundary.cert"  
  tls_key_file  = "/etc/pki/tls/boundary/boundary.key"
%{ endif }
	#proxy_protocol_behavior = "allow_authorized"
	#proxy_protocol_authorized_addrs = "127.0.0.1"
}

worker {
  # Name attr must be unique
	public_addr = "${public_ip}"
	name = "demo-worker-${name_suffix}"
	description = "A default worker created for demonstration"
	controllers = [
%{ for ip in controller_ips ~}
    "${ip}",
%{ endfor ~}
  ]
}

# must be same key as used on controller config
kms "aead" {
	purpose = "worker-auth"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_worker-auth"
}
