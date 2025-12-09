# Copyright IBM Corp. 2020, 2023
# SPDX-License-Identifier: MPL-2.0

output "boundary_url" {
  value = var.tls_disabled == false ? "https://${google_compute_address.public_controller_api.address}:${var.controller_api_port}" : "http://${google_compute_address.public_controller_api.address}:${var.controller_api_port}"
}

output "boundary_api_controller" {
  value = google_compute_address.public_controller_cluster.address
}

output "boundary_controller_port" {
  value = var.controller_cluster_port
}

output "recovery_key" {
  value = google_kms_crypto_key.recovery.name
}

output "crypto_ring" {
  value = google_kms_key_ring.this.name
}

output "gcp_project" {
  value = var.project
}

output "target_ip" {
  value = var.enable_target == 0 ? "Target not deployed, no valid IP address." : google_compute_instance.this[0].network_interface[0].network_ip
}