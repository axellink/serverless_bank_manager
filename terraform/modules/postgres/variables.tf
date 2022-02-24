variable "subnets" {
    type     = list(string)
    nullable = false

    description = "The list of subnets ids to attach the database to"
}