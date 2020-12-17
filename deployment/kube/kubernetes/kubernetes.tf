provider "kubernetes" {
  config_context_cluster = "minikube"
}

resource "kubernetes_config_map" "boundary" {
  metadata {
    name = "boundary-config"
  }

  data = {
    "boundary.hcl" = <<EOF
disable_mlock = true

    controller {
      name = "docker-controller"
      description = "A controller for a docker demo!"
      database {
          url = "env://BOUNDARY_PG_URL"
      }
    }

    worker {
      name = "docker-worker"
      description = "A worker for a docker demo"
      address = "0.0.0.0"
      controllers = ["0.0.0.0"]
      #public_addr = "myhost.mycompany.com"
    }

    listener "tcp" {
      address = "0.0.0.0"
      purpose = "api"
      tls_disable = true
    }

    listener "tcp" {
      address = "0.0.0.0"
      purpose = "cluster"
      tls_disable = true
    }

    listener "tcp" {
        address = "0.0.0.0"
        purpose = "proxy"
        tls_disable = true
    }

    kms "aead" {
      purpose = "root"
      aead_type = "aes-gcm"
      key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
      key_id = "global_root"
    }

    kms "aead" {
      purpose = "worker-auth"
      aead_type = "aes-gcm"
      key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
      key_id = "global_worker-auth"
    }

    kms "aead" {
      purpose = "recovery"
      aead_type = "aes-gcm"
      key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
      key_id = "global_recovery"
    }
EOF
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

resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          service = "redis"
          app     = "redis"
        }
      }

      spec {
        container {
          image = "redis"
          name  = "redis"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
    labels = {
      app = "redis"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}
