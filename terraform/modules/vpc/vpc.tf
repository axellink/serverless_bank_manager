# create VPC
resource "aws_vpc" "bank_manager_vpc" {
    cidr_block           = var.cidr_block
    enable_dns_hostnames = true
}

# create subnets
resource "aws_subnet" "vpc_subnets" {
    for_each = var.subnets

    vpc_id            = aws_vpc.bank_manager_vpc.id
    cidr_block        = each.value
    availability_zone = each.key

    tags = {
        Name = "bank_manager_subnets_${each.key}"
    }
}

# Create endpoints to Secrets Manager to let our lambda access it
resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
    vpc_id              = aws_vpc.bank_manager_vpc.id
    service_name        = "com.amazonaws.${var.region}.secretsmanager"
    vpc_endpoint_type   = "Interface"
    private_dns_enabled = true

    security_group_ids = [
        aws_vpc.bank_manager_vpc.default_security_group_id
    ]

    subnet_ids = [for i in aws_subnet.vpc_subnets : i.id]
}