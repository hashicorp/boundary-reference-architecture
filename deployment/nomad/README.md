# Nomad Deployment

This directory contains an example of deploying Boundary using Nomad

## Deploy

1. Create the nomad data directory

    ```bash
    $ sudo mkdir /opt/nomad
    $ sudo chown $USER /opt/nomad
    ```

2. Start the nomad agent

    ```bash
    $ nomad agent -config nomad-config.hcl
    ```

3. Initialize Terraform:

    ```bash
    $ terraform init
    ```

4. Run terraform apply against the nomad terraform module:

    ```bash
    $ terraform apply -target module.nomad
    ```

    Once boundary is running and the `boundary-init` job has run. 
    The controller service may restart a couple of times until the database initialization is finished.

5. Run terraform apply against the boundary terraform module:
    ```
    $ terraform apply -target module.boundary \
        -var "boundary_address=http://<public-ipv4-dns>:9200"
        -var "target_ips=10.0.0.1"
    ```
   

## Verify

- You can launch the admin console at `http://<public-ipv4-dns>:9200`.
You can verify what address it is by visiting the nomad admin console.
![nomad console](img/nomad.png)
- Select the `primary` org and then login with the user `admin` / `foofoofoo`.


## Connect

```bash
export BOUNDARY_ADDR="http://<public-ipv4-dns>:9200"
export BOUNDARY_AUTH_METHOD_ID="ampw_<some ID>"

boundary authenticate password \
  -login-name=admin \
  -password foofoofoo

boundary connect ssh \
  -target-scope-name="core_infra" \
  -target-name="backend_servers_ssh"
```


## Improvements

### Using Vault for Secrets

Since nomad has integration with vault, you can use it to store the database credentials.

```hcl
vault {
 policies     = ["boundary"]
}
```

```hcl

task "boundary-controller" {
   # ...
   template {
      data = <<EOF
controller {
  {{with secret "<kv-mount-point>/data/boundary/db"}}
  database {
      url = "postgresql://{{.Data.data.user}}:{{.Data.data.pass}}@127.0.0.1:5432/boundary?sslmode=disable"
  }
  {{end}}
}
   }
}
task "postgres" {
   # ...
   template {
      data        = <<EOT
{{ with secret "<kv-mount-point>/data/boundary/db" }}
POSTGRES_DB = "boundary"
POSTGRES_USER = "{{.Data.data.user}}"
POSTGRES_PASSWORD = "{{.Data.data.pass}}"
{{ end }}
EOT
      destination = "config.env"
      env         = true
   }
}
```

### Using Vault for KMS

Replace `kms "aead"` with `kms "vault"`.
Create the transit engine at the `boundary_kms` mount point.

```hcl
kms "transit" {
  purpose            = "root"
  address            = "https://vault:8200"
  disable_renewal    = "true"
  key_name           = "boundary_root_key"
  mount_path         = "boundary_kms/"
}
```

Make sure the Vault role that the nomad job assumes has the following policy:

```hcl
path "boundary_kms/encrypt/*" {
  capabilities = ["update"]
}
path "boundary_kms/decrypt/*" {
  capabilities = ["update"]
}
```

### Persistent data

Use host volumes to store the database in persistent storage.

In the `nomad-config.hcl` file, add:

```hcl
client {
 host_volume "boundary_db" {
      path      = "/opt/boundary/db"
      read_only = false
   }
}
```

In the `boundary.hcl` job file, add:

```hcl
group "boundary-db" {
   # ...
   volume "boundary_db" {
      type      = "host"
      source    = "boundary_db"
   }
   # ...
  task "postgres" {
     # ...
     volume_mount {
        volume      = "boundary_db"
        destination = "/var/lib/postgresql/data"
     }
     # ...
  }
}
```

### Other recommendations

- Redundant controllers
  - Increase the `count` property in the `boundary-controller` group.
- Use Consul connect (mTLS) for communication between the database and the controller
