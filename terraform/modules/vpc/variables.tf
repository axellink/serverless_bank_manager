variable "cidr_block" {
    type     = string
    nullable = false

    description = "The VPC cidr block"
}

variable "subnets" {
    type     = map(string)
    nullable = false

    description = "The map of subnets cidr, indexed by AZ"

    validation {
        condition     = length(var.subnets) >= 2
        error_message = "We need at least two subnets for the database."
    }
}

variable "region" {
    type     = string
    nullable = false
}