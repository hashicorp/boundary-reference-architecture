# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "kubernetes_deployment" "boundary" {
  metadata {
    name = "boundary"
    labels = {
      app = "boundary"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "boundary"
      }
    }

    template {
      metadata {
        labels = {
          app     = "boundary"
          service = "boundary"
        }
      }

      spec {
        volume {
          name = "boundary-config"

          config_map {
            name = "boundary-config"
          }
        }

        init_container {
          name  = "boundary-init"
          image = "hashicorp/boundary:latest"
          args = [
            "database",
            "init",
            "-config",
            "/boundary/boundary.hcl"
          ]

          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true

          }

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres:5432/boundary?sslmode=disable"
          }

          env {
            name  = "HOSTNAME"
            value = "boundary"
          }
        }

        container {
          image = "hashicorp/boundary:latest"
          name  = "boundary"

          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true
          }

          args = [
            "server",
            "-config",
            "/boundary/boundary.hcl"
          ]

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres:5432/boundary?sslmode=disable"
          }

          env {
            name  = "HOSTNAME"
            value = "boundary"
          }

          port {
            container_port = 9200
          }
          port {
            container_port = 9201
          }
          port {
            container_port = 9202
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 9200
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 9200
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "boundary_controller" {
  metadata {
    name = "boundary-controller"
    labels = {
      app = "boundary-controller"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "boundary"
    }

    port {
      name        = "api"
      port        = 9200
      target_port = 9200
    }
    port {
      name        = "cluster"
      port        = 9201
      target_port = 9201
    }
    port {
      name        = "data"
      port        = 9202
      target_port = 9202
    }
  }
}
