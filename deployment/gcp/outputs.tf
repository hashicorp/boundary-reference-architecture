output boundary_url {
  value = "Go to http://${module.gcp.boundary_api_public_ip}:${module.gcp.boundary_api_port} to access Boundary."
}

output recovery_key {
	value = module.gcp.recovery_key
}

output crypto_ring {
	value = module.gcp.crypto_ring
}

output gcp_project {
	value = module.gcp.gcp_project
}