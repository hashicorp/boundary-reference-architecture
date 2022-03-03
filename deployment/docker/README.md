# Docker Deployment

This directory contains an example deployment of Boundary using docker-compose and Terraform.

In this example, Boundary is deployed using the [hashicorp/boundary](https://hub.docker.com/r/hashicorp/boundary) Dockerhub image. The Boundary service ports are forwarded to the host machine to mimic being in a "public" network. Boundary is provisioned via Terraform to include targets for popular databases:

- mysql
- redis
- cassandra
- mssql server

All of these targets are on containers that are not port forwarded to the host machine in order to mimic them residing in a private network. Boundary is configured to reach these targets via Docker DNS (domain names defined by their service name in docker-compose). Clients can reach these targets via Boundary, and an example is given below using the redis-cli.

## Getting Started 

There is a helper script called `run` in this directory. You can use this script to deploy, login, and cleanup.

Start the docker-compose deployment:

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

Login to the UI:
  - Open browser to localhost:9200
  - Login Name: <any user from terraform var.users>
  - Password: foofoofoo
  - Auth method ID: find this in the UI when selecting the auth method or from TF output

If you did not use `./run login`, you can also login by hand:

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
installed on your host system). For example, we'll use [redis-cli](https://redis.io/topics/rediscli) to ping the Redis container via Boundary:

First find the target ID of the redis target:

```bash
boundary targets list -recursive -filter '"/item/name" matches "redis"'
```

And then connect:

```bash
$ boundary connect -exec redis-cli -target-id <ttcp_id> -- -p {{boundary.port}} ping
PONG
```

Explore the other containers such as Cassandra and Mysql (default passwords are set via env vars in the docker-compose.yml file).
