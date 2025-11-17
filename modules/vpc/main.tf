resource "aws_vpc" "vpc_main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.extra_tags, { Name = "${var.name_prefix} - vpc main" })
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = length(var.azs) >= length(var.public_subnet_cidrs) ? var.azs[count.index] : var.azs[0]
  map_public_ip_on_launch = true

  tags = merge(var.extra_tags, {
  Name = "${var.name_prefix} - public subnet - ${count.index + 1}" })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "Gateway"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc_main.id

  tags = merge(var.extra_tags, { Name = "public route table" })
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_route_table" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_eip" "eip" {
  count  = var.create_nat_per_az ? length(var.private_subnet_cidrs) : 1
  domain = "vpc"
  tags   = merge(var.extra_tags, { Name = "EIP - ${count.index + 1}" })
}

resource "aws_nat_gateway" "gw_nat" {
  count         = var.create_nat_per_az ? length(var.private_subnet_cidrs) : 1
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = merge(var.extra_tags, {
    Name = var.create_nat_per_az ? "GW NAT - ${count.index + 1}" : "GW NAT"
  })

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = length(var.azs) >= length(var.private_subnet_cidrs) ? var.azs[count.index] : var.azs[0]

  tags = merge(var.extra_tags, {
  Name = "${var.name_prefix} - private subnet - ${count.index + 1}" })
}

resource "aws_route_table" "route_table_private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc_main.id
  tags   = merge(var.extra_tags, { Name = "private route table - ${count.index + 1}" })
}

resource "aws_route" "private_route" {
  count                  = var.create_nat_per_az ? length(var.private_subnet_cidrs) : 1
  route_table_id         = aws_route_table.route_table_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw_nat[count.index].id
}

resource "aws_route_table_association" "private_route_table" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.route_table_private[count.index].id
}

