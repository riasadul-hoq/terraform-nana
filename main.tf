# AWS Provider & Profile has been declared
provider "aws" {
  region = "eu-west-3"
  profile = "contino_sandbox"
}

# Variable has been declared
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "avail_zone" {}
variable "route_table_cidr_block" {}

# VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


# Subnet in eu-west-3b AZ
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = { 
    Name = "${var.env_prefix}-subnet-1"
  }
}

# Default Route Table
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

/* # Route Table
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id 
  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "myapp-rta" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
} */