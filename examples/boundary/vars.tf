variable "url" {
  default = "http://127.0.0.1:9200"
  #  default = "http://boundary-demo-controller-ec52c62e6a9979ab.elb.us-east-1.amazonaws.com:9200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "Jim",
    "Mike",
    "Todd",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "Randall",
    "Susmitha",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "Jeff",
    "Pete",
    "Jonathan",
    "Malnick"
  ]
}

variable "backend_server_ips" {
  type    = set(string)
  default = []
}
