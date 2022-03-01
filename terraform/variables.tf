variable "region" {
  type     = string
  nullable = false

  description = "The region where to deploy application"
}

variable "profile" {
  type    = string
  default = "default"

  description = "Your AWS CLI profile"
}

variable "assume_role_arn" {
  type     = string
  nullable = true

  description = "Role ARN to assume if applicable"
}

variable "cidr_block" {
    type     = string
    nullable = false

    description = "The VPC cidr block"
}

variable "subnets" {
    type     = map(string)
    nullable = false

    description = "The map of subnets cidr, indexed by AZ"
}

variable "app_domain_name" {
  type     = string
  nullable = false

  description = "The application domain name"
}