#This is how you use Terraform Cloud, or your remote backend for TFE blah

terraform {
  backend "remote" {
    organization = "public-sector-se-1"

    workspaces {
      name = "boundary-reference-architecture"
    }
  }
}
