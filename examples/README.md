# Boundary Deployment Examples
This directory contains two deployment examples for Boundary using Terraform. The `aws/` directory contains an example AWS reference architecture codified in Terraform. The `boundary/` directory contains an example Terraform configuration for Boundary using the [Boundary Terraform Provider](https://github.com/hashicorp/terraform-provider-boundary).

## Requirements
- Terraform 0.13
- Go 1.15 or later 

## Deploy & Connect
To deploy this example:
- Make sure you have a local checkout of `github.com/hashicorp/boundary`
- Build the `boundary` binary for linux using `XC_OSARCH=linux/amd64 make dev`
- In the `example` directory, run `terraforom apply -target module.aws -var boundary_bin=<path to your binary>`
If your public SSH key you want to SSH to these hosts are not located at `~/.ssh/id_rsa.pub` then you'll also need to override that value.
- Once your AWS infra is live, you can SSH to your workers and controllers and see their configuration:
  - `ssh ubuntu@<controller-ip>`
  - `sudo systemctl status boundary-controller`
  - For workers, the systemd unit is called `boudnary-worker`
- Configure boundary using `terraform apply` (without the target flag), this will configure boundary per `boundary/main.tf`
- Open the LB in a browser `<LB URL>:9200, you should have a login screen.
- Login to the instance using one of the `backend_users` defined in the main.tf (or, if you saved the output from deploying the aws module, use the output from the init script for the default username/password)
- Find your org, then project, then targets. Save the ID of the target. 
- Find your auth methods, and save the auth method ID.
- Login on the CLI: `BOUNDARY_ADDR='http://boundary-demo-controller-<some sha>.elb.us-east-1.amazonaws.com:9200' boundary authenticate password -login-name=jim -password foofoofoo -auth-method-id=ampw_<some ID>`
- Connect to the target: `BOUNDARY_ADDR='http://boundary-demo-controller-b78759d1630f4aea.elb.us-east-1.amazonaws.com:9200' boundary connect -target-id ttcp_<some ID>` 
- Save the target IP and in another terminal window, SSH to the target host: `ssh -p<port from connect output> ubuntu@localhost`
