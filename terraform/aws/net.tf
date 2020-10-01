provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC resources
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "${var.tag}-${random_pet.test.id}-public"
  }
}



resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "${var.tag}-${random_pet.test.id}-private"
  }
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = local.tags
}

resource "aws_nat_gateway" "private" {
  subnet_id     = aws_subnet.private.id
  allocation_id = aws_eip.nat.id
  tags          = local.tags
}

# Public Routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tag}-${random_pet.test.id}-public"
  }
}

resource "aws_route_table_association" "public_subnets" {
  subnet_id      = aws_subnet.public.id
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
    Name = "${var.tag}-${random_pet.test.id}-private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private.id

  timeouts {
    create = "5m"
  }
}
