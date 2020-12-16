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
  }

  spec {


    replicas = 1

    selector {
      match_labels = {
        run = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          run = "postgres"
        }
      }

      spec {
        volume {
          name = "boundary-config"
        }

        init_container {
          name    = "postgres-init"
          image   = "hashicorp/boundary:0.1.2"
          command = ["database", "init", "-config", "/boundary/boundary.hcl"]
          volume_mount {
            name       = "boundary-config"
            mount_path = "/boundary"
            read_only  = true
          }

          env {
            name  = "BOUNDARY_PG_URL"
            value = "postgresql://postgres:postgres@127.0.0.1/boundary?sslmode=disable"
          }
        }

        container {
          image = "postgres"
          name  = "postgres"
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
  }

  spec {
    selector = {
      run = "postgres"
    }

    port {
      port     = 5432
      protocol = "TCP"
    }
  }
}
