variable "local_dir" {
    type = string
}

variable "account_id" {
    type = string
}

variable "secret_arn" {
    type = string
}

variable "region" {
    type = string
}

# Zip our lambdas
data "archive_file" "create_db_zip" {
    type        = "zip"
    source_dir  = format("%s/API/", var.local_dir)
    output_path = format("%s/DEP/api.zip", var.local_dir)
}