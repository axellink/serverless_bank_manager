locals {
    lambda_names = ["create_db", "hello"]
}

# First create role for the lambda
resource "aws_iam_role" "lambda_role" {
    for_each = toset(local.lambda_names)

    name = "lambda_${each.key}_role"
    

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
resource "aws_iam_policy" "lambda_log_policy"{
    for_each = toset(local.lambda_names)

    name        = "lambda_${each.key}_log_policy"
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
                    format("arn:aws:logs:%s:%s:log-group:/aws/lambda/%s:*", var.region, var.account_id, each.key)
                ]
            }
        ]
    })
}

# Finally tie them together
resource "aws_iam_role_policy_attachment" "lambda_log_policy_attachment" {
    for_each = aws_iam_role.lambda_role

    role       = each.value.name
    policy_arn = aws_iam_policy.lambda_log_policy[each.key].arn
}

# And we need secret to access db secrets
resource "aws_iam_role_policy_attachment" "lambda_access_db_secret_policy_attachment" {
    for_each = aws_iam_role.lambda_role

    role       = each.value.name
    policy_arn = aws_iam_policy.access_db_secret_policy.arn
}

# And we need permission to create EC2 interface
resource "aws_iam_role_policy_attachment" "lambda_EC2_interface_policy_attachment" {
    for_each = aws_iam_role.lambda_role

    role       = each.value.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Zip the source
data "archive_file" "create_zip" {
    for_each = toset(local.lambda_names)

    type        = "zip"
    source_dir  = "${var.local_dir}/API/scripts/${each.key}"
    output_path = "${var.local_dir}/API/build/${each.key}.zip"
}

# And then upload it
resource "aws_lambda_function" "lambda_create_db" {
    for_each = data.archive_file.create_zip

    filename      = each.value.output_path
    function_name = each.key
    role          = aws_iam_role.lambda_role[each.key].arn
    runtime       = "python3.8"
    handler       = "${each.key}.lambda_handler"
    layers        = [aws_lambda_layer_version.psycopg2.arn, aws_lambda_layer_version.bank_manager_helper.arn]

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
    function_name = "create_db"
    input         = "{}"
}