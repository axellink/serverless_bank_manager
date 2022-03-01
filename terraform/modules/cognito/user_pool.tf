resource "aws_cognito_user_pool" "bank_manager_user_pool" {
    name                     = "bank_manager_user_pool"
    username_attributes      = ["email"]
    auto_verified_attributes = ["email"]

    schema {
        name                = "nickname"
        attribute_data_type = "String"
        required            = true
        mutable             = true
        string_attribute_constraints{
            min_length = 1
            max_length = 50
        }
    }

    schema {
        name                = "email"
        attribute_data_type = "String"
        required            = true
        mutable             = false
        string_attribute_constraints{
            min_length = 1
            max_length = 1000
        }
    }

    account_recovery_setting {
        recovery_mechanism {
            name     = "verified_email"
            priority = 1
        }
    }

    verification_message_template {
        default_email_option = "CONFIRM_WITH_CODE"
    }
}

resource "aws_cognito_user_pool_client" "bank_manager_user_pool_client"{
    name = "bank_manager_user_pool_client"

    user_pool_id = aws_cognito_user_pool.bank_manager_user_pool.id

    allowed_oauth_flows  = ["code"]
    allowed_oauth_scopes = ["email", "openid"]

    callback_urls = ["https://${var.app_domain_name}/"]
    logout_urls   = ["https://${var.app_domain_name}/"]
}