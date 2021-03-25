data "google_compute_image" "this" {
  family  = var.compute_image_family
  project = var.compute_image_project
}

resource "google_compute_instance_template" "controller" {
  name_prefix    = local.boundary_controller_name
  machine_type   = var.compute_machine_type
  can_ip_forward = var.enable_ssh

  disk {
    source_image = data.google_compute_image.this.id
  }

  network_interface {
    subnetwork = google_compute_subnetwork.controller.id
    dynamic "access_config" {
      for_each = var.enable_ssh == true ? [0] : []
      content {}
    }
  }

  service_account {
    email  = google_service_account.boundary_controller.email
    scopes = ["cloud-platform"]
  }

  tags = var.boundary_controller_tags

  metadata = {
    ssh-keys = local.ssh_key_string
  }
  metadata_startup_script = templatefile("${path.module}/templates/boundary.hcl.tpl", {
    boundary_version               = var.boundary_version
    type                           = "controller"
    ca_name                        = google_privateca_certificate_authority.this.certificate_authority_id
		ca_issuer_location             = var.ca_issuer_location
    controller_api_listener_ip     = google_compute_address.public_controller_api.address
    controller_cluster_listener_ip = google_compute_address.public_controller_cluster.address
    controller_api_port            = var.controller_api_port
    controller_cluster_port        = var.controller_cluster_port
    worker_listener_ip             = google_compute_address.public_worker.address
    worker_port                    = var.worker_port
    project_id                     = var.project
    public_cluster_address         = google_compute_address.public_controller_cluster.address
    public_worker_address          = google_compute_address.public_worker.address
    db_endpoint                    = google_sql_database_instance.this.private_ip_address
    db_name                        = google_sql_database.this.name
    db_username                    = var.boundary_database_username
    db_password                    = var.boundary_database_password
    tls_disabled                   = var.tls_disabled
    tls_key_path                   = var.tls_key_path
    tls_cert_path                  = var.tls_cert_path
    kms_key_ring                   = google_kms_key_ring.this.name
    kms_worker_auth_key_id         = google_kms_crypto_key.worker_auth.name
    kms_recovery_key_id            = google_kms_crypto_key.recovery.name
    kms_root_key_id                = google_kms_crypto_key.root.name
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "controller" {
  name = local.boundary_controller_name

  version {
    instance_template = google_compute_instance_template.controller.id
    name              = var.boundary_version
  }

  base_instance_name = local.boundary_name

	update_policy {
		type                         = "PROACTIVE"
		instance_redistribution_type = "PROACTIVE"
		minimal_action               = "REPLACE"
		min_ready_sec                = 50
		replacement_method           = "RECREATE"
	}
}

resource "google_compute_region_autoscaler" "controller" {
  name   = local.boundary_controller_name
  target = google_compute_region_instance_group_manager.controller.id

  autoscaling_policy {
    max_replicas    = var.max_controller_replicas
    min_replicas    = var.min_controller_replicas
    cooldown_period = 60
  }
}

resource "google_compute_region_instance_group_manager" "worker" {
  name = local.boundary_worker_name

  version {
    instance_template = google_compute_instance_template.worker.id
    name              = var.boundary_version
  }

  base_instance_name = local.boundary_name

	update_policy {
		type                         = "PROACTIVE"
		instance_redistribution_type = "PROACTIVE"
		minimal_action               = "REPLACE"
		min_ready_sec                = 50
		replacement_method           = "RECREATE"
	}
}

resource "google_compute_region_autoscaler" "worker" {
  name   = local.boundary_worker_name
  target = google_compute_region_instance_group_manager.worker.id

  autoscaling_policy {
    max_replicas    = var.max_worker_replicas
    min_replicas    = var.min_worker_replicas
    cooldown_period = 60
  }
}

resource "google_compute_instance_template" "worker" {

  name_prefix    = local.boundary_worker_name
  machine_type   = var.compute_machine_type
  can_ip_forward = var.enable_ssh

  disk {
    source_image = data.google_compute_image.this.id
  }


  network_interface {
    subnetwork = google_compute_subnetwork.worker.id
    dynamic "access_config" {
      for_each = var.enable_ssh == true ? [0] : []
      content {}
    }
  }

  service_account {
    email  = google_service_account.boundary_worker.email
    scopes = ["cloud-platform"]
  }

  tags = var.boundary_worker_tags

  metadata = {
    ssh-keys = local.ssh_key_string
  }
  metadata_startup_script = templatefile("${path.module}/templates/boundary.hcl.tpl", {
    boundary_version               = var.boundary_version
    type                           = "controller"
    ca_name                        = google_privateca_certificate_authority.this.certificate_authority_id
		ca_issuer_location             = var.ca_issuer_location
    controller_api_listener_ip     = google_compute_address.public_controller_api.address
    controller_cluster_listener_ip = google_compute_address.public_controller_cluster.address
    controller_api_port            = var.controller_api_port
    controller_cluster_port        = var.controller_cluster_port
    worker_listener_ip             = google_compute_address.public_worker.address
    worker_port                    = var.worker_port
    project_id                     = var.project
    public_cluster_address         = google_compute_address.public_controller_cluster.address
    public_worker_address          = google_compute_address.public_worker.address
    db_endpoint                    = google_sql_database_instance.this.private_ip_address
    db_name                        = google_sql_database.this.name
    db_username                    = var.boundary_database_username
    db_password                    = var.boundary_database_password
    tls_disabled                   = var.tls_disabled
    tls_key_path                   = var.tls_key_path
    tls_cert_path                  = var.tls_cert_path
    kms_key_ring                   = google_kms_key_ring.this.name
    kms_worker_auth_key_id         = google_kms_crypto_key.worker_auth.name
    kms_recovery_key_id            = google_kms_crypto_key.recovery.name
    kms_root_key_id                = google_kms_crypto_key.root.name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "ssh" {
  count   = var.enable_ssh == true ? 1 : 0
  name    = "temporary-ssh-access"
  network = google_compute_network.this.name

  source_ranges = [var.my_public_ip]

  allow {
    protocol = "tcp"
    ports = [
      22
    ]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  target_tags = concat(var.boundary_controller_tags, var.boundary_worker_tags)

  direction = "INGRESS"
}