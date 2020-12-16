provider "kubernetes" {
  config_context_cluster = "minikube"
}

resource "kubernetes_config_map" "boundary" {
  metadata {
    name = "boundary-config"
  }

  data = {
    "boundary.hcl" = "${file("${path.module}/boundary.hcl")}"
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          service = "postgres"
          app     = "postgres"
        }
      }

      spec {
        container {
          image = "postgres"
          name  = "postgres"

          env {
            name  = "POSTGRES_DB"
            value = "boundary"
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "postgres"
          }

          port {
            container_port = 5432
          }

          liveness_probe {
            exec {
              command = ["psql", "-w", "-U", "postgres", "-d", "boundary", "-c", "SELECT", "1"]
            }
          }
        }
      }
    }
  }
}

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
        }

        init_container {
          name    = "boundary-init"
          image   = "hashicorp/boundary:0.1.2"
          command = ["/bin/sh", "-c"]
          args    = ["database", "init", "-config", "/boundary/boundary.hcl"]
          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true
          }
          env {
            name  = "POSTGRES_DB"
            value = "boundary"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres.postgres.svc:5432/boundary?sslmode=disable"
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
            name  = "POSTGRES_DB"
            value = "boundary"
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "postgres"
          }

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@postgres.postgres.svc:5432/boundary?sslmode=disable"
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
