locals {
    lambda_endpoints ={
        create_db = {uri: "/create_db", method: "POST"}
        hello     = {uri: "/hello" , method: "GET"}
    }
}

resource "aws_apigatewayv2_api" "bank_manager_api" {
    name          = "bank_manager_api"
    description   = "Gateway API for bank manager"
    protocol_type = "HTTP"

    cors_configuration {
        allow_credentials = false
        allow_headers     = ["*",]
        allow_methods     = ["*",]
        allow_origins     = ["*",]
        expose_headers    = ["*",]
        max_age           = 0
    }
}

resource "aws_apigatewayv2_stage" "test_stage" {
    api_id = aws_apigatewayv2_api.bank_manager_api.id

    name        = "test"
    auto_deploy = true
}

resource "aws_apigatewayv2_stage" "prod_stage" {
    api_id = aws_apigatewayv2_api.bank_manager_api.id

    name        = "prod"
    auto_deploy = false
}

resource "aws_apigatewayv2_authorizer" "bank_manager_user_authorizer" {
    name             = "bank_manager_user_authorizer"
    api_id           = aws_apigatewayv2_api.bank_manager_api.id
    authorizer_type  = "JWT"
    identity_sources = ["$request.header.Authorization"]

    jwt_configuration {
        audience = [var.cognito_client_id]
        issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_pool_id}"
    }
}

resource "aws_apigatewayv2_integration" "api_integrations" {
    for_each = local.lambda_endpoints

    api_id             = aws_apigatewayv2_api.bank_manager_api.id
    integration_uri    = aws_lambda_function.lambda_create_db["${each.key}"].invoke_arn
    integration_type   = "AWS_PROXY"
    integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_routes" {
    for_each = local.lambda_endpoints

    api_id    = aws_apigatewayv2_api.bank_manager_api.id
    route_key = "${each.value.method} ${each.value.uri}"
    target    = "integrations/${aws_apigatewayv2_integration.api_integrations["${each.key}"].id}"

    authorizer_id      = aws_apigatewayv2_authorizer.bank_manager_user_authorizer.id
    authorization_type = "JWT"
}

resource "aws_lambda_permission" "api_permissions" {
    for_each = local.lambda_endpoints

    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_create_db["${each.key}"].function_name
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.bank_manager_api.execution_arn}/*/*"
}