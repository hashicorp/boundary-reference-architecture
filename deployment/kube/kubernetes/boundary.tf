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
          name    = "boundary-init"
          image   = "hashicorp/boundary:0.1.2"
          command = ["/bin/sh", "-c"]
          args    = ["boundary database init -config /boundary/boundary.hcl"]

          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true

          }

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres:5432/boundary?sslmode=disable"
          }
        }

        container {
          image = "hashicorp/boundary:0.1.2"
          name  = "boundary"

          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true
          }

          command = ["/bin/sh", "-c"]
          args    = ["boundary server -config /boundary/boundary.hcl"]

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres:5432/boundary?sslmode=disable"
          }

          port {
            container_port = 9200
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "boundary" {
  metadata {
    name = "boundary"
    labels = {
      app = "boundary"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "boundary"
    }

    port {
      port        = 9200
      target_port = 9200
    }
  }
}
