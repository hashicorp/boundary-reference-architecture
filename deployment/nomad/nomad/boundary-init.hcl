job "boundary-init" {
  datacenters = ["dc1"]
  type        = "batch"

  group "boundary-init" {

    task "boundary-init" {
      driver = "docker"

      config {
        image = "hashicorp/boundary:0.8"

        volumes = [
          "local/boundary.hcl:/boundary/config.hcl"
        ]
        args = [
          "database", "init",
          "-skip-auth-method-creation",
          "-skip-host-resources-creation",
          "-skip-scopes-creation",
          "-skip-target-creation",
          "-config", "/boundary/config.hcl"
        ]
        cap_add = ["ipc_lock"]
      }

      template {
        data = <<EOF
controller {
  # This name attr must be unique across all controller instances if running in HA mode
  name = "{{env "NOMAD_ALLOC_ID"}}"
  public_cluster_addr = "{{ env "NOMAD_IP_cluster" }}"
  {{range nomadService "boundary-database"}}
  database {
      url = "postgresql://boundary:boundary@{{ .Address }}:{{ .Port }}/boundary?sslmode=disable"
  }
  {{end}}
}
# Root KMS configuration block: this is the root key for Boundary
kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
  key_id = "global_root"
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
    }
  }
}
