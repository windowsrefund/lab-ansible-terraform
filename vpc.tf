# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment
  }
}

# IGW
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Environment = var.environment
  }
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Environment = var.environment
  }
}

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = {
    Environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "public1_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Environment = var.environment
  }
}

resource "aws_subnet" "public2_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidrs["public2"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Environment = var.environment
  }
}

resource "aws_subnet" "private1_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Environment = var.environment
  }
}

resource "aws_subnet" "private2_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidrs["private2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Environment = var.environment
  }
}

# Subnet Associations
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

