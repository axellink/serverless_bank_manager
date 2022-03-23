variable "local_dir" {
    type = string
}

variable "account_id" {
    type = string
}

variable "secret_arn" {
    type = string
}

variable "region" {
    type = string
}

variable "cognito_pool_id" {
    type     = string
    nullable = false

    description = "ID of the User Pool for the authorizer"
}

variable "cognito_client_id" {
    type     = string
    nullable = false

    description = "ID of the User Pool CLIENT for the authorizer"
}

variable "subnets" {
    type     = list(string)
    nullable = false

    description = "The list of subnets ids to attach the lambdas to"
}

variable "security_groups" {
    type     = list(string)
    nullable = false

    description = "The list of subnets ids to attach the lambdas to"
}