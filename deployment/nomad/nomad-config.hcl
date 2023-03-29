client {
  enabled = true
}

server {
  enabled = true
  bootstrap_expect = 1
}

data_dir  = "/opt/nomad"
bind_addr = "0.0.0.0"

plugin "docker" {
  config {
    allow_caps = [
      # Default caps
      "audit_write",
      "chown",
      "dac_override",
      "fowner",
      "fsetid",
      "kill",
      "mknod",
      "net_bind_service",
      "setfcap",
      "setgid",
      "setpcap",
      "setuid",
      "sys_chroot",
      # Needed for mlock
      "ipc_lock"
    ]
  }
}
