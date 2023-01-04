# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "addr" {
  default = "http://127.0.0.1:9200"
}

variable "users" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
    "randy",
    "susmitha",
    "jeff",
    "pete",
    "harold",
    "patrick",
    "jonathan",
    "yoko",
    "brandon",
    "kyle",
    "justin",
    "melissa",
    "paul",
    "mitchell",
    "armon",
    "andy",
    "ben",
    "kristopher",
    "kris",
    "chris",
    "swarna",
    "mark",
    "julia",
  ]
}
