variable "addr" {
  default = "http://127.0.0.1:9200"
}

variable "users" {
  type = set(string)
  default = [
    "jeff",
  ]
}
