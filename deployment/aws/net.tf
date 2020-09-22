provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  private_subnet = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  public_subnet = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
  ]
}

# VPC resources
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.tag
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.tag
  }
}

# Subnets
resource "aws_subnet" "public_0" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "${var.tag}-public-0"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "${var.tag}-public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "${var.tag}-public-2"
  }
}

resource "aws_subnet" "private_0" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "${var.tag}-private-0"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.5.0/24"

  tags = {
    Name = "${var.tag}-private-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block        = "10.0.6.0/24"

  tags = {
    Name = "${var.tag}-private-2"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = var.tag
  }
}

resource "aws_nat_gateway" "private_0" {
  subnet_id     = aws_subnet.private_0.id
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "${var.tag}-private-0"
  }
}

# Public Routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tag}-public"
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = 3
  subnet_id      = local.public_subnet[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

# Private Routes
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tag}-private"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count          = 3
  subnet_id      = local.private_subnet[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_0.id

  timeouts {
    create = "5m"
  }
}


