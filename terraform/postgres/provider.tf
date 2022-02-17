variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "profile" {
  type    = string
  default = ""
}

variable "assume_role_arn" {
  type    = string
  default = ""
}

provider "aws" {
  region  = var.region
  profile = var.profile
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []
    content {
      role_arn = var.assume_role_arn
    }
  }
}

