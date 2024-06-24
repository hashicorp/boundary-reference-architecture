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


# Create boundary directory
mkdir /etc/boundary.d

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
sudo adduser --system --group boundary || true
sudo chown boundary:boundary /usr/bin/boundary

%{ if tls_disabled == false }
# Install cryptography module so we can request auto-generated certs from Google CAS
sudo apt-get install python3 python3-pip -y
mkdir /etc/boundary.d/tls
pip install --user "cryptography>=2.2.0"
export CLOUDSDK_PYTHON=python3
export CLOUDSDK_PYTHON_SITEPACKAGES=1

gcloud beta privateca certificates create \
  --issuer-pool ${ca_pool} \
  --issuer-location ${ca_issuer_location} \
  --generate-key \
  --key-output-file ${tls_key_path}/worker.key \
  --cert-output-file ${tls_cert_path}/worker.crt \
  --ip-san ${worker_listener_ip} \
export CLOUDSDK_PYTHON_SITEPACKAGES=0

# Take ownership of certificates
sudo chown boundary:boundary /etc/boundary.d/tls/worker.crt
sudo chown boundary:boundary /etc/boundary.d/tls/worker.key
%{ endif }

# Generate config file
cat <<EOF > /etc/boundary.d/boundary-worker.hcl

listener "tcp" {
  address = "${worker_listener_ip}:${worker_port}"
	purpose = "proxy"
%{ if tls_disabled == true }
	tls_disable = true
%{ else }
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}/worker.crt"
  tls_key_file  = "${tls_key_path}/worker.key"
%{ endif }

}

worker {
	public_addr = "${public_worker_address}"
	name = "$hostname"
	controllers = [
		"${public_cluster_address}"
  ]
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

sudo cat << EOF > /etc/systemd/system/boundary-worker.service
[Unit]
Description=boundary worker

[Service]
ExecStart=/usr/bin/boundary server -config /etc/boundary.d/boundary-worker.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

# Finish service configuration for boundary and start the service
sudo chown boundary:boundary /etc/boundary.d/boundary-worker.hcl
sudo chmod 664 /etc/systemd/system/boundary-worker.service
sudo systemctl daemon-reload
sudo systemctl enable boundary-worker
sudo systemctl start boundary-worker
