# Copyright IBM Corp. 2020, 2023
# SPDX-License-Identifier: MPL-2.0

resource "google_compute_network" "this" {
  name                    = local.boundary_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "controller" {
  name          = local.boundary_controller_name
  ip_cidr_range = var.controller_subnet == "" ? cidrsubnet(var.vpc_subnet, 4, 0) : var.controller_subnet
  network       = google_compute_network.this.id
}

resource "google_compute_subnetwork" "worker" {
  name          = local.boundary_worker_name
  ip_cidr_range = var.worker_subnet == "" ? cidrsubnet(var.vpc_subnet, 4, 1) : var.worker_subnet
  network       = google_compute_network.this.id
}

resource "google_compute_global_address" "this" {
  name          = local.boundary_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.this.id
}

resource "google_service_networking_connection" "this" {
  network = google_compute_network.this.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.this.name
  ]
}