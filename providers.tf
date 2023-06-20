provider "aviatrix" {
  username = "admin"
  controller_ip = var.ctrl_ip
  password = var.ctrl_password
}

terraform {
    required_providers {
      aviatrix = {
            source  = "aviatrixsystems/aviatrix"
            version = "3.1.0"
        }
    }
}

provider "aws" {
  region     = var.region
  access_key =  var.access_key
  secret_key = var.secret_key
}
