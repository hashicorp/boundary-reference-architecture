## Controller API load balancing
resource "google_compute_address" "public_controller_api" {
  name = local.boundary_controller_name
}

resource "google_compute_region_health_check" "controller_api" {
  name               = local.boundary_controller_api_name
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = var.controller_api_port
  }
}

resource "google_compute_forwarding_rule" "controller_api" {
  name            = local.boundary_controller_api_name
  ip_address      = google_compute_address.public_controller_api.address
  backend_service = google_compute_region_backend_service.controller_api.id
  port_range      = var.controller_api_port
  ip_protocol     = "TCP"
}

resource "google_compute_region_backend_service" "controller_api" {
  name = local.boundary_controller_name
  health_checks = [
    google_compute_region_health_check.controller_api.id
  ]
  load_balancing_scheme = "EXTERNAL"
  backend {
    group          = google_compute_region_instance_group_manager.controller.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_firewall" "api" {
  name    = local.boundary_controller_api_name
  network = google_compute_network.this.name

  source_ranges = var.client_source_ranges

  allow {
    protocol = "tcp"
    ports = [
      var.controller_api_port
    ]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  target_tags = var.boundary_controller_tags

  direction = "INGRESS"
}

### Controller cluster load balancing
resource "google_compute_address" "public_controller_cluster" {
  name = local.boundary_controller_cluster_name
}

resource "google_compute_region_health_check" "controller_cluster" {
  name               = local.boundary_controller_cluster_name
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = var.controller_cluster_port
  }
}

resource "google_compute_forwarding_rule" "controller_cluster" {
  name            = local.boundary_controller_cluster_name
  ip_address      = google_compute_address.public_controller_cluster.address
  backend_service = google_compute_region_backend_service.controller_cluster.id
  port_range      = var.controller_cluster_port
  ip_protocol     = "TCP"
}

resource "google_compute_region_backend_service" "controller_cluster" {
  name = local.boundary_controller_cluster_name
  health_checks = [
    google_compute_region_health_check.controller_cluster.id
  ]
  load_balancing_scheme = "EXTERNAL"
  backend {
    group          = google_compute_region_instance_group_manager.controller.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_firewall" "cluster" {
  name    = local.boundary_controller_cluster_name
  network = google_compute_network.this.name

  source_tags   = var.boundary_worker_tags
  source_ranges = var.worker_source_ranges != [] ? var.worker_source_ranges : null

  allow {
    protocol = "tcp"
    ports = [
      var.controller_cluster_port
    ]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  target_tags = var.boundary_controller_tags

  direction = "INGRESS"
}

### Worker load balancing
resource "google_compute_address" "public_worker" {
  name = local.boundary_worker_name
}

resource "google_compute_forwarding_rule" "worker" {
  name            = local.boundary_worker_name
  backend_service = google_compute_region_backend_service.worker.id
  port_range      = var.worker_port
  ip_address      = google_compute_address.public_worker.address
}

resource "google_compute_region_backend_service" "worker" {
  name                  = local.boundary_worker_name
  load_balancing_scheme = "EXTERNAL"
  health_checks = [
    google_compute_region_health_check.worker.id
  ]
  backend {
    group          = google_compute_region_instance_group_manager.worker.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_region_health_check" "worker" {
  name               = local.boundary_worker_name
  check_interval_sec = 1
  timeout_sec        = 1
  http_health_check {
    port = var.worker_port
  }
}

resource "google_compute_firewall" "health_checks" {
  name    = "${local.boundary_name}-health-checks"
  network = google_compute_network.this.name

  source_ranges = [
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]

  allow {
    protocol = "tcp"
    ports = [
      var.controller_api_port,
      var.controller_cluster_port,
      var.worker_port
    ]
  }
  direction = "INGRESS"
	target_tags = concat(var.boundary_controller_tags, var.boundary_worker_tags)
}

resource "google_compute_firewall" "worker" {
  name    = local.boundary_worker_name
  network = google_compute_network.this.name

  source_ranges = var.client_source_ranges

  allow {
    protocol = "tcp"
    ports = [
      var.worker_port
    ]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  target_tags = var.boundary_worker_tags

  direction = "INGRESS"
}
