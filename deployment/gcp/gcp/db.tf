# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "google_sql_database_instance" "this" {
  depends_on = [
    google_compute_global_address.this,
    google_service_networking_connection.this
  ]
  name                = local.boundary_name
  database_version    = var.postgres_version
  deletion_protection = false

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.this.id
    }
  }
}

resource "google_sql_database" "this" {
  name     = local.boundary_name
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "this" {
  name     = var.boundary_database_username
  instance = google_sql_database_instance.this.name
  password = var.boundary_database_password
}
