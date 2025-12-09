# Copyright IBM Corp. 2020, 2023
# SPDX-License-Identifier: MPL-2.0

provider "kubernetes" {
  config_context_cluster = "minikube"
  config_path            = "~/.kube/config"
}
