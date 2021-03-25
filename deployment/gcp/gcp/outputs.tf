output boundary_api_public_ip {
  value = google_compute_address.public_controller_api.address
}

output boundary_api_port {
  value = var.controller_api_port
}

output boundary_api_controller {
  value = google_compute_address.public_controller_cluster.address
}

output boundary_controller_port {
  value = var.controller_cluster_port
}

output recovery_key {
	value = google_kms_crypto_key.recovery.name
}

output crypto_ring {
	value = google_kms_key_ring.this.name
}

output gcp_project {
	value = var.project
}