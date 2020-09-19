variable "url" {
  default = "http://127.0.0.1:9200"
  #  default = "http://boundary-demo-controller-ec52c62e6a9979ab.elb.us-east-1.amazonaws.com:9200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "Jim Lambert",
    "Mike Gaffney",
    "Todd Knight",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "Randall Morey",
    "Susmitha Girumala",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "Jeff Mitchell",
    "Pete Pacent",
    "Jonathan Thomas (JT)",
    "Jeff Malnick"
  ]
}

variable "backend_server_ips" {
  type    = set(string)
  default = []
}
