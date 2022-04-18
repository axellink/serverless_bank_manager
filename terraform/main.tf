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

module "cognito" {
  source = "./modules/cognito"

  app_domain_name = var.app_domain_name
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
  subnets    = var.subnets
  region     = var.region
}

module "database" {
  source  = "./modules/postgres"
  subnets = module.vpc.subnets_ids
}

module "api" {
  source            = "./modules/api"
  local_dir         = "${path.root}/.."
  account_id        = data.aws_caller_identity.current.account_id
  secret_arn        = module.database.secret_arn
  region            = var.region
  cognito_pool_id   = module.cognito.cognito_pool_id
  cognito_client_id = module.cognito.cognito_client_id
  
  subnets         = module.vpc.subnets_ids
  security_groups = [module.vpc.security_group_id]

  depends_on = [module.database, module.vpc]
}

output "create_db_output" {
  value = module.api.create_db_out
}

output "cognito_pool_id" {
  value = module.cognito.cognito_pool_id
}

output "cognito_client_id" {
  value = module.cognito.cognito_client_id
}

output "api_uri" {
  value = module.api.test_api_uri
}