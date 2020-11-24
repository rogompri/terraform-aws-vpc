## Main VPC ##
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr 
  enable_dns_support   = var.vpc_dns_support
  enable_dns_hostnames = var.vpc_dns_hostnames
  tags                 = {
    Name = var.vpc_name
  }
}

## VPC Subnets ##
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index}"
  }
}

## Internet Gateway ##
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

## NAT Gateway ##
resource "aws_eip" "eip_nat" {
  count = var.nat_gw == true ? length(var.private_subnets) : 0 
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw"{
  count         = var.nat_gw == true ? length(var.private_subnets) : 0
  allocation_id = aws_eip.eip_nat[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags          = {Name = "${var.vpc_name}-natgw-${count.index}"}
}

## Public Route Tables ##
resource "aws_route_table" "public_rt" {
  count   = length(aws_subnet.public_subnet)
  vpc_id  = aws_vpc.main_vpc.id
  tags    = {"Name" = "${var.vpc_name}-public-rt-${count.index}"}
}

resource "aws_route" "r1" {
  count                  = length(aws_route_table.public_rt)
  route_table_id         = aws_route_table.public_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_a" {
  count          = length(aws_route_table.public_rt)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[count.index].id
}

## Private Route Tables ##
resource "aws_route_table" "private_rt" {
  count   = length(aws_subnet.private_subnet)
  vpc_id  = aws_vpc.main_vpc.id
  tags    = {"Name" = "${var.vpc_name}-private-rt-${count.index}"}
}

resource "aws_route" "r2" {
  count                  = var.nat_gw == true ? length(aws_route_table.private_rt) : 0
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
}

resource "aws_route_table_association" "private_rt_a" {
  count          = length(aws_route_table.private_rt)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
