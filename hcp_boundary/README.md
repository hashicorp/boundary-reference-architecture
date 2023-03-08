# Boundary Deployment Examples on HCP
This directory contains examples for configuring Boundary using Terraform. While many of these configurations can be used on a Boundary OSS environment, this has been created to facilitate using HCP Boundary in real-world scenarios.

## Requirements
- The latest [version of Boundary](https://www.boundaryproject.io/downloads) in your PATH variable
- The latest version of [Terraform](https://www.terraform.io/downloads)
- Build the `boundary` binary for linux using `XC_OSARCH=linux/amd64 make dev` or download from our [release page](https://boundaryproject.io/) on our docs site.
- An HCP Boundary environment, available at https://portal.cloud.hashicorp.com/

## Deploy
To deploy the examples in this repo, see the README in each subdirectory