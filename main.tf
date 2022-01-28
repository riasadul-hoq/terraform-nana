# AWS Provider & Profile has been declared
provider "aws" {
  region = "eu-west-3"
  profile = "contino_sandbox"
}


/*
# VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


# Subnet Module - Created by us
module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
  avail_zone = var.avail_zone
  route_table_cidr_block = var.route_table_cidr_block
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}
*/

# Terraform VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
    
  }
}


# Webserver Module
module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = module.vpc.vpc_id
  my_ip = var.my_ip
  sg_ingress_cidr_block = var.sg_ingress_cidr_block
  sg_egress_cidr_block = var.sg_egress_cidr_block
  env_prefix = var.env_prefix
  image_name = var.image_name
  subnet_id = module.vpc.public_subnets[0]
  avail_zone = var.avail_zone
  instance_type = var.instance_type
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location

}