# Docker + Consul-Terraform-Sync (CTS) Deployment

This directory contains an example deployment of Boundary using docker-compose, Terraform, and Consul-Terraform-Sync (CTS).

In this example, Boundary is deployed using the [hashicorp/boundary](https://hub.docker.com/r/hashicorp/boundary) Dockerhub image. The Boundary service ports are forwarded to the host machine to mimic being in a "public" network. Boundary is provisioned via Terraform and targets for popular databases (redis and mysql) are discovered from Consul catalog and configured via Consul-Terraform-Sync (CTS). If you don't already have CTS, you can learn how to install it [here](https://www.consul.io/docs/nia/installation/install).

All of these targets are on containers that are not port forwarded to the host machine in order to mimic them residing in a private network. Boundary is configured to reach these targets via Docker DNS (domain names defined by their service name in docker-compose). Clients can reach these targets via Boundary, and an example is given below using the redis-cli.

## Getting Started 

There is a helper script called `run` in this directory. You can use this script to deploy, login, and cleanup.

Start the docker-compose Boundary and Consul deployment and configure the environment via Terraform:

```bash
./run all
```

To login your Boundary CLI:

```bash
./run login
```

To stop all containers and start from scratch:

```bash
./run cleanup
```

At this point, Boundary still does not have targets configured for the redis and mysql containers registered in the Consul catalog.

Navigate to the `compose` directory. To update Boundary target configurations for redis and mysql with Consul-Terraform-Sync:

```bash
consul-terraform-sync -config-file cts/config.hcl
```

Login to the UI:
  - Open browser to localhost:9200
  - Login Name: <any user from var.users>
  - Password: foofoofoo
  - Auth method ID: You can find the auth method ID for the `primary` org in the UI and selecting the auth method or from TF output

Note: You can also get the auth method id via the cli with 
```bash
boundary auth-methods list -recursive
```

Authenticate to Boundary:
```bash
$ boundary authenticate password -login-name jeff -password foofoofoo -auth-method-id <get_from_console_or_tf>

Authentication information:
  Account ID:      apw_gAE1rrpnG2
  Auth Method ID:  ampw_Qrwp0l7UH4
  Expiration Time: Fri, 06 Nov 2020 07:17:01 PST
  Token:           at_NXiLK0izep_s14YkrMC6A4MajKyPekeqTTyqoFSg3cytC4cP8sssBRe5R8cXoerLkG7vmRYAY5q1Ksfew3JcxWSevNosoKarbkWABuBWPWZyQeUM1iEoFcz6uXLEyn1uVSKek7g9omERHrFs
```

## Connect to Private Redis

Once the deployment is live, you can connect to the containers (assuming their clients are
installed on your host system). You can get target ids with `boundary targets list -recursive`. For example, we'll use [redis-cli](https://redis.io/topics/rediscli) to ping the Redis container via Boundary:

```bash
$ boundary connect -exec redis-cli -target-id ttcp_Mgvxjg8pjP -- -p {{boundary.port}} ping
PONG
```

Explore the other containers such Mysql (default passwords are set via env vars in the docker-compose.yml file).

## Extra-Credit: Add OIDC Authentication

This example includes a resource for a Boundary OIDC auth method and Boundary OIDC user account in `terraform\main.tf`. These resources are commented-out by default but can be used to add support for OIDC authentication for your Boundary environment. This allows you to delegate user authentication to popular identity providers (IDP) like Azure Active Directory, Okta, and Auth0. For more information on how to configure these OIDC resources with information from your IDP, see the [Boundary learn tutorial for configuring OIDC auth methods](https://learn.hashicorp.com/tutorials/boundary/oidc-auth?in=boundary/configuration).
