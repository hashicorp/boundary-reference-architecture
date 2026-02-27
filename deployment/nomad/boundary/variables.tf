variable "boundary_address" {
  default = "http://localhost:9200"
}

variable "target_ips" {
  type    = set(string)
  default = ["127.0.0.1"]
}
