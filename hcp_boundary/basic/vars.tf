variable "origin_url" {
    type = string
    # Add your origin URL here, 
    # You can find your origin once you've enabled Boundary at https://portal.cloud.hashicorp.com/
    # Note: cannot have a terminating '/' character
    default = "https://ad49ddeb-b903-4f6e-acb1-2da9a62dd9c3.boundary.hashicorp.cloud"
}

variable "auth_method_id" {
    type = string
    # Login to your Boundary environment and copy the "password" auth method ID that was created at deployment
    # Login -> Auth methods -> "password"
    default = "ampw_IeiNTNRPVI"
}

variable "bootstrap_user_login_name" {
    type = string
    # the username chosen of the user created when you enabled Boundary
    sensitive =true
    }

variable "bootstrap_user_password" {
    type = string
    sensitive = true
    # the password chosen of the user created when you enabled Boundary
}

variable "target_ips" {
  type    = set(string)
  # Add in IPs for any targets you would like to add
  default = ["127.0.0.1"]
}