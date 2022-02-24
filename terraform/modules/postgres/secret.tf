resource "aws_secretsmanager_secret" "db_secrets" {
    name                    = "database_secrets"
    recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_secrets_version" {
    secret_id     = aws_secretsmanager_secret.db_secrets.id
    secret_string = <<EOF
    {
        "username": "${aws_db_instance.bank_manager_db.username}",
        "password": "${aws_db_instance.bank_manager_db.password}",
        "hostname": "${aws_db_instance.bank_manager_db.address}",
        "port": "${aws_db_instance.bank_manager_db.port}",
        "dbname": "${aws_db_instance.bank_manager_db.db_name}"
    }
    EOF
}