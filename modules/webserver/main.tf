# Default Security Group
resource "aws_default_security_group" "main-sg" {
  vpc_id = var.vpc_id
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

/*
# Security Group
resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = var.vpc_id
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

# Fetch AMI
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
    #values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
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
  
  subnet_id = var.subnet_id

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

