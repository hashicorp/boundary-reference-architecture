variable "url" {
  default = "http://127.0.0.1:9200"
  #  default = "http://boundary-demo-controller-ec52c62e6a9979ab.elb.us-east-1.amazonaws.com:9200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "randy",
    "susmitha",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "jeff",
    "pete",
    "jonathan",
    "malnick"
  ]
}

variable "target_ips" {
  type    = set(string)
  default = []
}

variable "kms_recovery_key_id" {
  default = ""
}
