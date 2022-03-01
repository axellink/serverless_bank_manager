output "cognito_pool_id" {
    value = aws_cognito_user_pool.bank_manager_user_pool.id
}

output "cognito_client_id" {
    value = aws_cognito_user_pool_client.bank_manager_user_pool_client.id
}