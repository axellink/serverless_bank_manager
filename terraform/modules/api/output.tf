output "create_db_out" {
  value = aws_lambda_invocation.action_create_db.result
}

output "test_api_uri" {
  value = "${aws_apigatewayv2_api.bank_manager_api.api_endpoint}/test"
}

output "api_uri" {
  value = "${aws_apigatewayv2_api.bank_manager_api.api_endpoint}"
}