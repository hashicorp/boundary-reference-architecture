# Copyright IBM Corp. 2020, 2026
# SPDX-License-Identifier: MPL-2.0

provider "kubernetes" {
  config_context_cluster = "minikube"
  config_path            = "~/.kube/config"
}
