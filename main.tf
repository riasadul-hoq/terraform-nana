# AWS Provider & Profile has been declared
provider "aws" {
  region = "eu-west-3"
  profile = "contino_sandbox"
}

# Variable Blocks
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "avail_zone" {}
variable "route_table_cidr_block" {}
variable "my_ip" {}
variable "sg_ingress_cidr_block" {}
variable "sg_egress_cidr_block" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "private_key_location" {}

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

/* 
# Route Table
resource "aws_route_table" "myapp-rtb" {
  vpc_id = aws_vpc.myapp-vpc.id 
  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

# Route Table Association
resource "aws_route_table_association" "myapp-rta" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
} 

# Security Group
resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.sg_ingress_cidr_block]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.sg_egress_cidr_block]
    prefix_list_ids = []
    }
    tags = {
      Name = "${var.env_prefix}-sg"
    }
}
*/

# Default Security Group
resource "aws_default_security_group" "main-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.sg_ingress_cidr_block]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.sg_egress_cidr_block]
    prefix_list_ids = []
    }
    tags = {
      Name = "${var.env_prefix}-main-sg"
    }
}

# Fetch AMI
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
}

# Output Latest AMI ID
output "latest-amazon-linux-image-id" {
  value = data.aws_ami.latest-amazon-linux-image.id

}


#Create Key Pair
resource "aws_key_pair" "myapp-ssh-key" {
  key_name = "myapp-ssh-key"
  public_key = file(var.public_key_location)
}


# Create EC2 Instance based on Latest AMI ID
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.main-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.myapp-ssh-key.key_name

  #user_data = file("startup-script.sh")

  # Connection strings for remote-exec provisioner
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.private_key_location)
    host = self.public_ip
  }
  
  # File provisioner to copy script
  provisioner "file" {
   source = "startup-script.sh"
   destination = "/home/ec2-user/startup-script.sh"
  }
  
  # Remote provisioner to execute script
  provisioner "remote-exec" {
   #script = file("startup-script.sh")
   inline = [
     "chmod +x /home/ec2-user/startup-script.sh",
    "/home/ec2-user/startup-script.sh args" 
   ]
  }

  # Local provisioner to save public IP address
  provisioner "local-exec" {
   command = "echo ${self.public_ip} > EC2-public-ip.txt"
  
  }

  tags = {
      Name = "${var.env_prefix}-server"
    }

}

# Output EC2 Public IP
output "EC2-public-ip" {
  value = aws_instance.myapp-server.public_ip

}