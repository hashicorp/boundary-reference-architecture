# Google Cloud provider variables
variable "project" {
  default = "go-gcp-demos"
}

variable "location" {
  default = "australia-southeast1"
}

# Boundary binary variables
variable "boundary_version" {
  type        = string
  description = "Leaving this blank defaults to pull down the latest binary."
  default     = ""
}

# Boundary networking variables
variable "vpc_subnet" {
  type        = string
  description = "The CIDR used by your VPC subnet. This will be peered with the GCP managed VPC for CloudSQL, which requires a minimum of a /24."
  default     = "192.168.10.0/24"
}

variable "controller_subnet" {
  type        = string
  description = "Optional variable that configures the subnetwork CIDR. By default this will be calculated as a function of the VPC CIDR."
  default     = ""
}

variable "worker_subnet" {
  type        = string
  description = "Optional variable that configures the subnetwork CIDR. By default this will be calculated as a function of the VPC CIDR."
  default     = ""
}

variable "client_source_ranges" {
  type        = list(any)
  description = "The source CIDR ranges that should be able to access Boundary."
  default = [
    "0.0.0.0/0"
  ]
}

variable "worker_source_ranges" {
  type        = list(any)
  description = "A range of IPs/CIDRs for workers NOT deployed with this module that should be able to register with the Boundary controller."
  default     = []
}

# Boundary KMS variables
variable "kms_crypto_key_rotation_period" {
  type        = string
  description = "The number of seconds after which your keys will be rotated."
  default     = "100000s"
}


# Boundary database variables
variable "boundary_database_name" {
  type        = string
  description = "The name used when creating your Boundary database."
  default     = "boundary"
}

variable "boundary_database_username" {
  type        = string
  description = "The username that will be created and used for controller connection to your database."
  default     = "boundary"
}

variable "boundary_database_password" {
  type        = string
  description = "The password that will be created and used for controller connection to your database."
  default     = "boundary"
}

variable "postgres_version" {
  type        = string
  description = "Postgres version to be used. Boundary has only been tested with 12+."
  default     = "POSTGRES_12"
}

variable "database_tier" {
  type        = string
  description = "The instance size for CloudSQL"
  default     = "db-f1-micro"
}

# Boundary compute variables
variable "compute_image_family" {
  type        = string
  description = "The name of the family which you source your image from. This module leverages apt for software installation, so your choice should be a debian based distro."
  default     = "ubuntu-1804-lts"
}

variable "compute_image_project" {
  type        = string
  description = "The name of the family which you source your image from. This module leverages apt for software installation, so your choice should be a debian based project."
  default     = "ubuntu-os-cloud"
}

variable "compute_machine_type" {
  type        = string
  description = "The size of the controller and worker nodes that will be created."
  default     = "e2-medium"
}

variable "max_worker_replicas" {
  type        = number
  description = "The maximum number of nodes in the worker autoscaling group."
  default     = 5
}
variable "min_worker_replicas" {
  type        = number
  description = "The minimum number of nodes in the worker autoscaling group."
  default     = 2
}

variable "max_controller_replicas" {
  type        = number
  description = "The maximum number of nodes in the autoscaling group."
  default     = 5
}
variable "min_controller_replicas" {
  type        = number
  description = "The minimum number of nodes in the controller autoscaling group."
  default     = 2
}

variable "controller_instance_can_ip_forward" {
  type        = bool
  description = "Determines whether the instance can perform IP forwarding."
  default     = false
}

variable "worker_instance_can_ip_forward" {
  type        = bool
  description = "Determines whether the instance can perform IP forwarding."
  default     = false
}

variable "boundary_controller_tags" {
  type        = list(any)
  description = "A set of tags that are applied to your controllers. Used with security groups."
  default = [
    "boundary-controller"
  ]
}

variable "boundary_worker_tags" {
  type        = list(any)
  description = "A set of tags that are applied to your workers. Used with security groups."
  default = [
    "boundary-worker"
  ]
}

# Boundary listener variables
variable "controller_api_port" {
  type        = number
  description = "The port on which the controller api service will listen."
  default     = 9200
}

variable "controller_cluster_port" {
  type        = number
  description = "The port on which the controller cluster service will listen."
  default     = 9201
}

variable "worker_port" {
  type        = number
  description = "The port on which the worker service will listen."
  default     = 9202
}

# Boundary PKI Variables
variable "ca_organization" {
  default = "HashiCorp"
}

variable "ca_common_name" {
  default = "boundary.local"
}

variable "ca_subject_alternate_names" {
  default = []
}

variable "tls_disabled" {
  default = false
}

variable "tls_cert_path" {
  default = "/etc/boundary.d/tls"
}

variable "tls_key_path" {
  default = "/etc/boundary.d/tls"
}

variable "ca_issuer_location" {
  type        = string
  description = ""
  default     = "asia-east1"
}

# Debugging variables
variable "enable_ssh" {
  default = false
}

variable "my_public_ip" {
  default = ""
}

variable "ssh_username" {
  type        = string
  description = "The name of the user which you want to set the SSH public certificate for."
  default     = "ubuntu"
}

variable "ssh_key_path" {
  type        = string
  description = "The absolute path to the public certificate of your SSH key."
  default     = ""
}

#Enable or disable an example target machine.
variable "enable_target" {
  type        = bool
  description = "Use to toggle creating a compute instance that can be used as a target for Boundary. Note that to connect you will also need to configure the ssh_key_path variable."
  default     = true
}