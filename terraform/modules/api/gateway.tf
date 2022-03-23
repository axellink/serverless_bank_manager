locals {
    lambda_endpoints ={
        create_db = "/create_db"
        hello     = "/hello"
    }
}

resource "aws_apigatewayv2_api" "bank_manager_api" {
    name          = "bank_manager_api"
    description   = "Gateway API for bank manager"
    protocol_type = "HTTP"
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