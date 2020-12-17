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

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}
