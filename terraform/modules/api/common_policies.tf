resource "aws_iam_policy" "access_db_secret_policy" {
    name = "access_db_secret_policy"
    path = "/"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Sid = "VisualEditor0",
                Effect = "Allow",
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ],
                Resource = format("arn:aws:secretsmanager:%s:%s:secret:%s", var.region, var.account_id, regex("[A-Za-z0-9-]+$",var.secret_arn))
            }
        ]
    })
}