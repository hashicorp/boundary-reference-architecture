# Kubernetes Deployment

This directory contains an example deployment of Boundary using Kubernetes and Terraform.

In this example, Boundary is deployed using the [hashicorp/boundary](https://hub.docker.com/r/hashicorp/boundary) Dockerhub image. The Boundary service ports are forwarded to the host machine to mimic being in a "public" network. Boundary is provisioned via Terraform to include a redis target.

The Redis target is a container running on Kubernetes. At the end of this exmaple you'll be able to run Boundary on Minikube along with Redis and use Boundary to access the Redis command line prompt.

The intent of this example is to show an example Boundary deployment on Kubernetes and how to access other services running on that Kubernetes cluster using Boundary.  

## Getting Started

### Requirements
- Terraform 0.13
- Go 1.15 or later
- Minikube
- Optional: Redis CLI for target access

### Deploy

Start minikube:

```
$ minikube start
```

Initialize Terraform:

```
$ terraform init
```

Run terraform apply against the kubernetes terraform module:

```
$ terraform apply -target module.kubernetes
```

Expose the Boundary controller service for provisioning (note that this will open a browser to where you can 
login to Boundary but because we haven't provisioned Boundary yet, that won't be possible. You can 
ignore or close this window. All we need from this is the route to the Boundary server so Terraform
can provision it):

```
$ minikube service boundary-controller
```

Run terraform apply against the boundary terraform module using the value for Boundary's 
address found in the previous command:

```
$ terraform apply -target module.boundary -var boundary_addr=<MINIKUBE EXPOSED URL>
```

### Verify

Check the deployments:

```
$ kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
boundary   1/1     1            1           12m
postgres   1/1     1            1           12m
redis      1/1     1            1           12m
```

Have minikube tunnel into the Boundary pod:

```
$ minikube service boundary
|-----------|----------|-------------|--------------|
| NAMESPACE |   NAME   | TARGET PORT |     URL      |
|-----------|----------|-------------|--------------|
| default   | boundary |             | No node port |
|-----------|----------|-------------|--------------|
😿  service default/boundary has no node port
🏃  Starting tunnel for service boundary.
|-----------|----------|-------------|------------------------|
| NAMESPACE |   NAME   | TARGET PORT |          URL           |
|-----------|----------|-------------|------------------------|
| default   | boundary |             | http://127.0.0.1:53480 |
|-----------|----------|-------------|------------------------|
🎉  Opening service default/boundary in default browser...
❗  Because you are using a Docker driver on darwin, the terminal needs to be open to run it.

```

This should also open a browser window with the Boundary login info. You can login with the 
user credentials setup with Terraform (user: jeff, pw: foofoofoo).

Note the URL to Boundary in this step because we'll use it later.

### Login to Boundary

In the shell you intend to run `boundary` commands, export the `BOUNDARY_ADDR` variable with 
the value from the `minikube service` command:

```
$ export BOUNDARY_ADDR=<minikube service url value>
```

Get the auth method ID for the password auth method in the `primary` scope. We're going to use 
some jq foo to to get the correct ID (remember resource ID's are unique, so yours will be different
from the one I get here): 

```
$ boundary auth-methods list -scope-id $(boundary scopes list -format json | jq -c ".[] | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"')

Auth Method information:
  ID:             ampw_1234567890
    Description:  Provides initial administrative authentication into Boundary
    Name:         Generated global scope initial auth method
    Type:         password
    Version:      1
```

Now login:

```
$ boundary authenticate password -login-name=jeff -password=foofoofoo -auth-method-id=ampw_1234567890
```

From the UI or the CLI, grab the target ID for the redis container in the databases project. If
you're doing this on the CLI, you'll want to list the scopes from the `primary` org scope we 
created using Terraform:

```
$ boundary scopes list
<get scope ID for primary org>
$ boundary scopes list -scope-id <primary org ID>
```

Once you have the databases project scope ID, you can list the targets (again, using some JQ foo to get the correct scope ID for the `primary` scope).

For simplicity, here's a one-liner to list the targets at project scope within the `primary` org scope:

```
$ boundary targets list -scope-id $(boundary scopes list -format json -scope-id $(boundary scopes list -format json | jq -c ".[] | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"') | jq ".[].id" | tr -d '"')
```

You'll want the target ID for the Redis container. Use that target ID to start a session:

```
$ boundary connect -exec redis-cli -target-id <redis target id> -- -h {{boundary.ip}} -p {{boundary.port}}
```
