# Boundary Deployment Examples
This directory contains two deployment examples for Boundary using Terraform. The `aws/` directory contains an example AWS reference architecture codified in Terraform. The `boundary/` directory contains an example Terraform configuration for Boundary using the [Boundary Terraform Provider](https://github.com/hashicorp/terraform-provider-boundary).

## Notable Differences from Reference Diagram
1. Controllers are deployed into the public subnet for ease of automation (act as bastions)
1. Using hard coded KMS AEAD keys instead of AWS Key Management Service

