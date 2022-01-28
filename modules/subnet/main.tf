# Subnet in eu-west-3b AZ
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = var.vpc_id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = { 
    Name = "${var.env_prefix}-subnet-1"
  }
}

# Default Route Table
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id
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
  vpc_id = var.vpc_id 
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

/* 
# Route Table
resource "aws_route_table" "myapp-rtb" {
  vpc_id = var.vpc_id  
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

*/