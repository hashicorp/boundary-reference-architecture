# Boundary Deployment Example on AWS
This directory contains an AWS deployment example for Boundary using Terraform. The `aws/aws/` directory contains an example AWS reference architecture codified in Terraform and will deploy infrastructure consisting of 2 controllers, 1 worker, and 1 target. The `aws/boundary/` directory contains an example Terraform configuration for setting up and configuring Boundary resources using the [Boundary Terraform Provider](https://github.com/hashicorp/terraform-provider-boundary).

## Requirements
- Terraform 0.13
- Go 1.15 or later 

## Setup
- Make sure you have a local checkout of `github.com/hashicorp/boundary`
- Build the `boundary` binary for linux using `XC_OSARCH=linux/amd64 make dev` or download from our [release page](https://boundaryproject.io/) on our docs site.
- Provide appropriate AWS credentials through the command line

## Deploy
To deploy this example:

1. Clone this repo by running `git clone https://github.com/hashicorp/boundary-reference-architecture.git`
2. Navigate to `boundary-reference-architecture/deployment/aws`
    
    If you want to change your AWS region, navigate to `aws/aws/net.tf` and change `region = <new-region>`
    
    In addition, run the command `export AWS_REGION=<new-region>` to set the region in your command line
3. Run `terraform init`
4. Run terraform apply and provide the path to where your binary is stored 

    For example: `terraform apply -target module.aws -var boundary_bin=/usr/bin`  

    If the public SSH key you want use is not located at `~/.ssh/id_rsa.pub` then you'll also need to override that value:
    ```
    terraform apply -target module.aws -var boundary_bin=<path to your binary> -var pub_ssh_key_path=<path to your SSH public key>
    ```
    If the private key is not named the same as the public key but without the .pub suffix and/or is not stored in the same directory, you can use the `priv_ssh_key_path` variable also to point to its location; otherwise its filename will be inferred from the filename of the public key.

6. Configure boundary using `terraform apply` (without the target flag), this will configure boundary per `boundary/main.tf`

## Verify
- Once your AWS infrastructure is live, you can SSH to your workers and controllers and see their configuration:
  - `ssh ubuntu@<controller-ip>`
  - `sudo systemctl status boundary-controller`
  - For workers, the systemd unit is called `boundary-worker`
  - The admin console will be available at `http://<public-ipv4-dns>:9200`

## Login
- Open the console in a browser and login to the instance using one of the `backend_users` defined in the main.tf (or, if you saved the output from deploying the aws module, use the output from the init script for the default username/password)
- Find your org, then project, then targets. Save the ID of the target. 
- Find your auth methods, and save the auth method ID.
- Login on the CLI: 

```
BOUNDARY_ADDR='http://<public-ipv4-dns>:9200' \
  boundary authenticate password \
  -login-name=jim \
  -password foofoofoo \
  -auth-method-id=ampw_<some ID>
```

You can also use this login name in the Boundary console that you navigated to in the verify step.

## Connect

Connect to the target in the private subnet via Boundary:

```
BOUNDARY_ADDR='http://<public-ipv4-dns>:9200' \
  boundary connect ssh --username ubuntu -target-id ttcp_<generated_id>
```

## Reference
![](arch.png)
