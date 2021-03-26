# Boundary Deployment Examples
This directory contains two deployment examples for Boundary using Terraform. The `gcp/` directory contains an example AWS reference architecture codified in Terraform. The `boundary/` directory contains an example Terraform configuration for Boundary using the [Boundary Terraform Provider](https://github.com/hashicorp/terraform-provider-boundary).

## Requirements
- Terraform 0.13 or later

## Deploy
To deploy this example:
- In the `example` directory, run:

```
terraform apply
```

SSH is disabled by default, but can be toggled on with `-var enable_ssh=true`. To connect, you will need to set the absolute path to your ssh public key with `-var ssh_key_path=path_to_my_ssh_key/id_rsa.pub`.

TLS is enabled by default, and leverages the beta certificate authority service on GCP.

## Verify
- Once your GCP infra is live, you can SSH to your workers and controllers and see their configuration:
  - `ssh ubuntu@<controller-ip>`
  - `sudo systemctl status boundary-controller`
  - For workers, the systemd unit is called `boundary-worker`
  - The admin console url will be passed through as an output.

## Configure Boundary
- Configure boundary by changing into the boundary directoy, and using `terraform apply` (without the target flag), this will configure boundary per `boundary/main.tf`

## Login
- Open the console in a browser and login to the instance using one of the `backend_users` defined in the main.tf (or, if you saved the output from deploying the aws module, use the output from the init script for the default username/password)
- Find your org, then project, then targets. Save the ID of the target.
- Find your auth methods, and save the auth method ID.
- Login on the CLI:

```
BOUNDARY_ADDR='https://<boundary_url>' \
  boundary authenticate password \
  -login-name=jim \
  -password foofoofoo \
  -auth-method-id=ampw_<some ID>
```

You can also use this login name in the Boundary console that you navigated to in the verify step.

## Connect

Connect to the target in the private subnet via Boundary:

```
BOUNDARY_ADDR='http://<boundary_url>' \
  boundary connect ssh --username ubuntu -target-id ttcp_<generated_id>
```
