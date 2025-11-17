output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "igw_id" {
  value = aws_internet_gateway.gw.id
}

output "vpc_id" {
  value = aws_vpc.vpc_main.id
}