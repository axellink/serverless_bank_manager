# First create role for the lambda
resource "aws_iam_role" "lambda_create_db_role" {
    name = "lambda_create_db_role"
    

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# then create the log policy
resource "aws_iam_policy" "lambda_create_db_log_policy"{
    name        = "lambda_create_db_log_policy"
    path        = "/"
    description = "Policy for a lambda to create log"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = "logs:CreateLogGroup",
                Resource = format("arn:aws:logs:%s:%s:*", var.region, var.account_id)
            },
            {
                Effect = "Allow",
                Action = [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Resource = [
                    format("arn:aws:logs:%s:%s:log-group:/aws/lambda/%s:*", var.region, var.account_id, "create_db")
                ]
            }
        ]
    })
}

# Finally tie them together
resource "aws_iam_role_policy_attachment" "lambda_create_db_log_policy_attachment" {
    role      = aws_iam_role.lambda_create_db_role.name
    policy_arn = aws_iam_policy.lambda_create_db_log_policy.arn
}

# And we need secret to access db secrets
resource "aws_iam_role_policy_attachment" "lambda_create_db_access_db_secret_policy_attachment" {
    role      = aws_iam_role.lambda_create_db_role.name
    policy_arn = aws_iam_policy.access_db_secret_policy.arn
}

# And we need permission to create EC2 interface
resource "aws_iam_role_policy_attachment" "lambda_create_db_EC2_interface_policy_attachment" {
    role       = aws_iam_role.lambda_create_db_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Zip the source
data "archive_file" "create_db_zip" {
    type        = "zip"
    source_dir  = format("%s/API/scripts/create_db", var.local_dir)
    output_path = format("%s/API/build/create_db.zip", var.local_dir)
}

# And then upload it
resource "aws_lambda_function" "lambda_create_db" {
    filename      = data.archive_file.create_db_zip.output_path
    function_name = "create_db"
    role          = aws_iam_role.lambda_create_db_role.arn
    runtime       = "python3.8"
    handler       = "create_db.lambda_handler"
    layers        = [aws_lambda_layer_version.psycopg2.arn]


    environment {
      variables = {
          SECRETS_ARN = var.secret_arn
          SECRETS_REGION = var.region
      }
    }

    vpc_config {
      subnet_ids = var.subnets
      security_group_ids = var.security_groups
    }
}

# Invoke lambda to create database
resource "aws_lambda_invocation" "action_create_db" {
    function_name = aws_lambda_function.lambda_create_db.function_name
    input         = "{}"
}

output "create_db_out" {
  value = aws_lambda_invocation.action_create_db.result
}