resource "aws_db_subnet_group" "vpc_subnets" {
  name       = "bank_manager_db_subnet_group"
  subnet_ids = var.subnets

  tags = {
    Name = "bank_manager_db_subnet_group"
  }
}

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
  db_subnet_group_name    = aws_db_subnet_group.vpc_subnets.name
}