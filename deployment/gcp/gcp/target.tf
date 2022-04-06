resource "random_shuffle" "this" {
  count        = var.enable_target == 0 ? 0 : 1
  input        = data.google_compute_zones.this.names
  result_count = 1
}

resource "google_compute_instance" "this" {
  count        = var.enable_target == 0 ? 0 : 1
  name         = "${local.boundary_name}-target"
  zone         = random_shuffle.this[0].result[0]
  machine_type = var.compute_machine_type

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.id
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.worker.id
  }

  tags = ["boundary-target"]

  metadata = {
    ssh-keys = local.ssh_key_string
  }
}

resource "google_compute_firewall" "target" {
  count   = var.enable_target == 0 ? 0 : 1
  name    = "${local.boundary_name}-target"
  network = google_compute_network.this.name

  source_tags = var.boundary_worker_tags

  allow {
    protocol = "tcp"
    ports = [
      22
    ]
  }

  target_tags = ["boundary-target"]

  direction = "INGRESS"
}


