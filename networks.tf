# Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "master-vpc-jenkins"
  }
}

# Create VPC in us-west-2
resource "aws_vpc" "vpc_worker" {
  provider             = aws.region_worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "worker-vpc-jenkins"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw_master" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
}

# Create IGW in us-west-2
resource "aws_internet_gateway" "igw_worker" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_worker.id
}

# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region_master
  state    = "available"
}

# Create subnet #1 in us-east-1
resource "aws_subnet" "subnet_1_master" {
  provider          = aws.region_master
  availability_zone = data.aws_availability_zones.azs.names[0]
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}

# Create subnet #2 in us-east-1
resource "aws_subnet" "subnet_2_master" {
  provider          = aws.region_master
  availability_zone = data.aws_availability_zones.azs.names[1]
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
}

# Create subnet #1 in us-west-2
resource "aws_subnet" "subnet_1_worker" {
  provider   = aws.region_worker
  vpc_id     = aws_vpc.vpc_worker.id
  cidr_block = "192.168.1.0/24"
}

# Initiate peering connection request from us-east-1
resource "aws_vpc_peering_connection" "useast1_uswest2" {
  provider    = aws.region_master
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.aws_region_worker
  peer_vpc_id = aws_vpc.vpc_worker.id
}

# Accept VPC peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept_useast1" {
  provider                  = aws.region_worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1_uswest2.id
  auto_accept               = true
}

# Create route table in us-east-1
resource "aws_route_table" "useast1_route_table" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_master.id
  }

  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1_uswest2.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "Master-Region-RT"
  }
}

# Overwrite default route table of VPC(Master) with our route table
resource "aws_main_route_table_association" "set_master_default_rt_assoc" {
  provider       = aws.region_master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.useast1_route_table.id
}

# Create route table in us-west-2
resource "aws_route_table" "uswest2_route_table" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_worker.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_worker.id
  }

  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1_uswest2.id
  }

  route {
    cidr_block                = "10.0.2.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1_uswest2.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "Worker-Region-RT"
  }
}

# Overwrite default route table of VPC(Master Oregon) with our route table
resource "aws_main_route_table_association" "set_worker_default_rt_assoc" {
  provider       = aws.region_worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.uswest2_route_table.id
}
