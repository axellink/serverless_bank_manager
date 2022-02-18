module "database" {
  source          = "./postgres"
  profile         = "CONFIGME"
  db_password     = "CONFIGME"
#  region          = "CONFIGME MAYBE"
#  assume_role_arn = "CONFIGME MAYBE"
}
