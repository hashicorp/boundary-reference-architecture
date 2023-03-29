job "boundary" {
  datacenters = ["dc1"]
  type        = "service"

  reschedule {
    delay          = "30s"
    delay_function = "constant"
    unlimited      = true
  }

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    canary            = 0
    stagger           = "30s"
  }

  group "boundary-controller" {
    count = 1

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    restart {
      interval = "10m"
      attempts = 2
      delay    = "15s"
      mode     = "fail"
    }

    network {
      port "api" {
        static = 9200
        to     = 9200
      }

      port "cluster" {
        static = 9201
        to     = 9201
      }
    }

    service {
      name     = "boundary-controller"
      provider = "nomad"
      port     = "api"
    }

    service {
      name     = "boundary-cluster"
      provider = "nomad"
      port     = "cluster"
    }

    task "boundary-controller" {
      driver = "docker"

      config {
        image = "hashicorp/boundary:0.8"

        volumes = [
          "local/boundary.hcl:/boundary/config.hcl"
        ]
        ports   = ["api", "cluster"]
        cap_add = ["ipc_lock"]  # Needed for mlock
      }

      template {
        data = <<EOF
controller {
  name = "{{env "NOMAD_ALLOC_ID"}}"
  description = "Demo controller running on Nomad"
  public_cluster_addr = "{{ env "NOMAD_IP_cluster" }}"
  {{range nomadService "boundary-database"}}
  database {
      url = "postgresql://boundary:boundary@{{ .Address }}:{{ .Port }}/boundary?sslmode=disable"
  }
  {{end}}
}
# API listener configuration block
listener "tcp" {
  address = "0.0.0.0:9200"
  purpose = "api"
  cors_allowed_origins = ["serve://boundary"]
  tls_disable = true
}
# Data-plane listener configuration block (used for worker coordination)
listener "tcp" {
  address = "0.0.0.0:9201"
  purpose = "cluster"
}
# Root KMS configuration block: this is the root key for Boundary
kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
  key_id = "global_root"
}
# Worker authorization KMS
kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_worker-auth"
}
# Recovery KMS block: configures the recovery key for Boundary
kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_recovery"
}
EOF

        destination = "local/boundary.hcl"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }

  group "boundary-worker" {
    count = 1

    network {
      port "proxy" {
        static = 9202
        to     = 9202
      }
    }

    task "boundary-worker" {
      driver = "docker"

      config {
        image = "hashicorp/boundary:0.8"

        volumes = [
          "local/boundary.hcl:/boundary/config.hcl",
        ]
        ports   = ["proxy"]
        cap_add = ["ipc_lock"]
      }

      template {
        data = <<EOF
# Proxy listener configuration block
listener "tcp" {
  address = "0.0.0.0"
  purpose = "proxy"
}
worker {
  name = "{{ env "NOMAD_ALLOC_ID" }}"
  description = "Worker on {{ env "attr.unique.hostname" }}"
  public_addr = "{{ env "NOMAD_IP_proxy" }}"
  controllers = [
     {{ range nomadService "boundary-cluster" }}
        "{{ .Address }}:{{ .Port }}",
     {{ end }}
  ]
}
# Worker authorization KMS
kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_worker-auth"
}
EOF

        destination = "local/boundary.hcl"
      }

      resources {
        cpu    = 1000
        memory = 512
      }
    }
  }

  group "boundary-db" {
    count = 1

    network {
      port "psql" {
        to = 5432

      }
    }

    service {
      name     = "boundary-database"
      provider = "nomad"
      port     = "psql"
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "postgres"
        ports = ["psql"]
      }

      template {
        data        = <<EOT
POSTGRES_DB = "boundary"
POSTGRES_USER = "boundary"
POSTGRES_PASSWORD = "boundary"
EOT
        destination = "config.env"
        env         = true
      }
    }
  }
}
