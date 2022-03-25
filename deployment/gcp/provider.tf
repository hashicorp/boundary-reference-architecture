
terraform {
  #backend "gcs" {}

  required_providers {
    google-beta = "= 3.70.0"
  }

}

provider "google" {
  project = var.project
  region  = var.region
}

