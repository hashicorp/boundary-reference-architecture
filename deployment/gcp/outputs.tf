output boundary_url {
  value = module.gcp.boundary_url
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

output helper_text {
	value = <<-EOF
"These outputs assist with running the included boundary configuration. To do so, please take the following steps:
1. export URL=${module.gcp.boundary_url} && export RECOVERY_KEY=${module.gcp.recovery_key} && export KEY_RING=${module.gcp.crypto_ring} && export GCP_PROJECT=${module.gcp.gcp_project}
2. cd ./boundary && terraform init
3. terraform plan -var url=$URL -var key_ring=$KEY_RING  -var recovery_key=$RECOVERY_KEY -var gcp_project=$GCP_PROJECT
4. terraform apply -var url=$URL -var key_ring=$KEY_RING  -var recovery_key=$RECOVERY_KEY -var gcp_project=$GCP_PROJECT"
EOF
}