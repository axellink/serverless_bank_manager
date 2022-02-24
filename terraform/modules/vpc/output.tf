output "subnets_ids" {
    value = [for i in aws_subnet.vpc_subnets : i.id]
}

output "security_group_id" {
    value = aws_vpc.bank_manager_vpc.default_security_group_id
}