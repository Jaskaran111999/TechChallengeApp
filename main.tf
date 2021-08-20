provider "aws" {
  region = "ap-southeast-2"
}

#VPC
resource "aws_vpc" "vpc-servian" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "vpc-servian"
    Resource = "servian"
  }
}

#subnets
resource "aws_subnet" "pub-subnet-2a" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.0/26"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "pub-subnet-2a"
    Resource = "servian"
  }
}

resource "aws_subnet" "pub-subnet-2b" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.64/26"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "pub-subnet-2b"
    Resource = "servian"
  }
}

resource "aws_subnet" "pri-subnet-2a" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.128/26"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "pri-subnet-2a"
    Resource = "servian"
  }
}

resource "aws_subnet" "pri-subnet-2b" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.192/26"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "pri-subnet-2b"
    Resource = "servian"
  }
}

#internet gateway
resource "aws_internet_gateway" "igw-servian" {
  vpc_id = aws_vpc.vpc-servian.id

  tags = {
    Name = "igw-servian"
    Resource = "servian"
  }
}

#elasic IP
resource "aws_eip" "eip-servian" {
  vpc = true

  tags = {
    Name = "eip-servian"
    Resource = "servian"
  }

  depends_on = [aws_internet_gateway.igw-servian]
}

#public nat gateway
resource "aws_nat_gateway" "nat-servian" {
  allocation_id = aws_eip.eip-servian.id
  subnet_id = aws_subnet.pub-subnet-2a.id

  tags = {
    Name = "nat-servian"
    Resource = "servian"
  }

  depends_on = [aws_internet_gateway.igw-servian]
}

#to manage default route table for vpc-servian
resource "aws_default_route_table" "rtb-pri" {
  default_route_table_id = aws_vpc.vpc-servian.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-servian.id}"
  }

  tags = {
    Name = "rtb-pri"
    Resource = "servian"
  }
}

#public route table
resource "aws_route_table" "rtb-pub" {
  vpc_id = aws_vpc.vpc-servian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-servian.id
  }

  tags = {
    Name = "rtb-pub"
    Resource = "servian"
  }
}

#security groups
resource "aws_security_group" "lb-sgroup" {
  name = "Internet access"
  description = "Allow incoming traffic to Load Balancer"
  vpc_id = aws_vpc.vpc-servian.id

  ingress {
    description = "Allow traffic to Load Balancer"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [aws_vpc.vpc-servian.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-sgroup"
    Resource = "servian"
  }
}

/*
resource "aws_security_group" "app-sgroup" {
  name = "App security group"
  description = "Allow incoming traffic from Load Balancer, Database and ECS service"
  vpc_id = aws_vpc.vpc-servian.id

  ingress {
    description = "Allow traffic from Load Balancer"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.lb-sgroup.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sgroup"
    Resource = "servian"
  }
}
*/

#Load Balancer
resource "aws_lb" "lb-servian" {
  name = "lb-servian"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb-sgroup.id]
  subnets = [aws_subnet.pub-subnet-2a.id, aws_subnet.pub-subnet-2b.id]

  enable_deletion_protection = true

  tags = {
    Name = "lb-servian"
    Resource = "servian"
  }
}

