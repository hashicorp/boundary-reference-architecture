#!/bin/bash
hostname=$(hostname)

# Install official HashiCorp Repository and install Boundary
sudo apt-get update
sudo apt-get install curl -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
%{ if boundary_version != "" }
sudo apt-get update && sudo apt-get install boundary=${boundary_version} -y
%{ else }
sudo apt-get update && sudo apt-get install boundary -y
%{ endif }


# Create boundary directories
mkdir /etc/boundary.d

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
sudo adduser --system --group boundary || true
sudo chown boundary:boundary /usr/bin/boundary

%{ if tls_disabled == false }
# Install cryptography module so we can request auto-generated certs from Google CAS
sudo apt-get install python-pip -y
mkdir /etc/boundary.d/tls
pip install --user "cryptography>=2.2.0"
export CLOUDSDK_PYTHON=python
export CLOUDSDK_PYTHON_SITEPACKAGES=1

gcloud beta privateca certificates create \
  --issuer ${ca_name} \
	--issuer-location ${ca_issuer_location} \
  --generate-key \
  --key-output-file ${tls_key_path}/api.key \
  --cert-output-file ${tls_cert_path}/api.crt \
  --ip-san ${controller_api_listener_ip} \
  --reusable-config "leaf-server-tls"

gcloud beta privateca certificates create \
  --issuer ${ca_name} \
	--issuer-location ${ca_issuer_location} \
  --generate-key \
  --key-output-file ${tls_key_path}/controller.key \
  --cert-output-file ${tls_cert_path}/controller.crt \
  --ip-san ${controller_cluster_listener_ip} \
  --reusable-config "leaf-server-tls"
export CLOUDSDK_PYTHON_SITEPACKAGES=0

# Take ownership of certificates
sudo chown boundary:boundary /etc/boundary.d/tls/api.crt
sudo chown boundary:boundary /etc/boundary.d/tls/api.key
sudo chown boundary:boundary /etc/boundary.d/tls/controller.crt
sudo chown boundary:boundary /etc/boundary.d/tls/controller.key
%{ endif }

#Generate config file
cat <<EOF > /etc/boundary.d/boundary-controller.hcl
disable_mlock = true

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

controller {
  name        = "$hostname"
  description = "A controller for a demo!"

  database {
    url = "postgresql://${db_username}:${db_password}@${db_endpoint}/${db_name}"
  }
	public_cluster_addr = "${public_cluster_address}"
}

listener "tcp" {
  address                           = "${controller_api_listener_ip}:${controller_api_port}"
	purpose                           = "api"
%{ if tls_disabled == true }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}/api.crt"
  tls_key_file  = "${tls_key_path}/api.key"
%{ endif }
	cors_enabled                      = true
	cors_allowed_origins              = ["*"]
}

listener "tcp" {
  address                           = "${controller_cluster_listener_ip}:${controller_cluster_port}"
	purpose                           = "cluster"
%{ if tls_disabled == true }
	tls_disable                       = true
%{ else }
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}/controller.crt"
  tls_key_file  = "${tls_key_path}/controller.key"
%{ endif }
}

kms "gcpckms" {
  purpose     = "root"
  key_ring    = "${kms_key_ring}"
  crypto_key  = "${kms_root_key_id}"
	project     = "${project_id}"
	region      = "global"
}

kms "gcpckms" {
  purpose     = "worker-auth"
  key_ring    = "${kms_key_ring}"
  crypto_key  = "${kms_worker_auth_key_id}"
	project     = "${project_id}"
	region      = "global"
}

kms "gcpckms" {
  purpose     = "recovery"
  key_ring    = "${kms_key_ring}"
  crypto_key  = "${kms_recovery_key_id}"
	project     = "${project_id}"
	region      = "global"
}
EOF

# Install the boundary as a service for systemd on linux

sudo cat << EOF > /etc/systemd/system/boundary-controller.service
[Unit]
Description=boundary controller

[Service]
ExecStart=/usr/bin/boundary server -config /etc/boundary.d/boundary-controller.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Make sure to initialize the DB before starting the service. This will result in
# a database already initizalized warning if another controller or worker has done this 
# already, making it a lazy, best effort initialization
boundary database init -skip-auth-method-creation -skip-host-resources-creation -skip-scopes-creation -skip-target-creation -config /etc/boundary.d/boundary-controller.hcl || true


# Finish service configuration for boundary and start the service
sudo chown boundary:boundary /etc/boundary.d/boundary-controller.hcl
sudo chmod 664 /etc/systemd/system/boundary-controller.service
sudo systemctl daemon-reload
sudo systemctl enable boundary-controller
sudo systemctl start boundary-controller
