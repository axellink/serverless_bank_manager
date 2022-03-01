resource "aws_lambda_layer_version" "psycopg2" {
    filename   = format("%s/API/deps/psycopg2.zip", var.local_dir)
    layer_name = "psycopg2"

    compatible_runtimes = ["python3.8"]
}

# Create the bank_manager_helper layer
resource "aws_lambda_layer_version" "bank_manager_helper" {
    filename   = format("%s/API/build/bank_manager_helper.zip", var.local_dir)
    layer_name = "bank_manager_helper"

    compatible_runtimes = ["python3.8"]
}