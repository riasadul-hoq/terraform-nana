provider "aws" {
  region = "eu-west-3"
  profile = "contino_sandbox"
}


variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "avail_zone" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = { 
    Name = "${var.env_prefix}-subnet-1"
  }
}
