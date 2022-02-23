variable "region" {
  type    = string
  default = ""
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

data "aws_caller_identity" "current" {}

/*
module "database" {
  source = "./modules/postgres"
}
//*/

module "api" {
  source     = "./modules/api"
  local_dir  = "/home/avanzaghi/Documents/Perso/dev/serverless_bank_manager"
  account_id = data.aws_caller_identity.current.account_id
  secret_arn = "arn:aws:secretsmanager:eu-west-1:006775341395:secret:test-uKgH4k"
  region     = var.region
}
