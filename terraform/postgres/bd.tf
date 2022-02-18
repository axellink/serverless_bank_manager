resource "aws_db_instance" "bank_manager_db" {
  allocated_storage       = 20
  db_name                 = "bank_manager"
  username                = "bank_manager"
  identifier              = "bank-manager"
  password                = random_password.password.result
  engine                  = "postgres"
  engine_version          = "14.1"
  instance_class          = "db.t3.micro"
  backup_retention_period = 0
  # This is needed to avoid creating snapshot when deleting database
  skip_final_snapshot     = true
}

/*
Just a reminder that this DB will be created in default VPC for development
When things will be ready, I shall create a VPC with two subnets in separated AZ
and then create a DB subnet group with those two subnets in it and attach
database to it so :
TODO : VPC when it's prod ready
*/
