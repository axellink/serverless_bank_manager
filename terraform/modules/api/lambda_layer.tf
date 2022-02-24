resource "aws_lambda_layer_version" "psycopg2" {
    filename   = format("%s/API/deps/psycopg2.zip", var.local_dir)
    layer_name = "psycopg2"

    compatible_runtimes = ["python3.8"]
}