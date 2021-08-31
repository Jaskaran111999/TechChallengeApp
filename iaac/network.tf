#network.tf


resource "aws_vpc" "vpc-servian" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "vpc-servian"
    Resource = "servian"
  }
}

#will setup 2 public and a private subnet
resource "aws_subnet" "pub-subnet-2a" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.0/26"
  availability_zone = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-2a"
    Resource = "servian"
  }
}

resource "aws_subnet" "pub-subnet-2b" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.64/26"
  availability_zone = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-2b"
    Resource = "servian"
  }
}

#private subnet in ap-southeast-2a region
resource "aws_subnet" "pri-subnet-2a" {
  vpc_id = aws_vpc.vpc-servian.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "pri-subnet-2a"
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

resource "aws_route_table_association" "pub-rtb-assoc-2a" {
  subnet_id = aws_subnet.pub-subnet-2a.id
  route_table_id = aws_route_table.rtb-pub.id
}

resource "aws_route_table_association" "pub-rtb-assoc-2b" {
  subnet_id = aws_subnet.pub-subnet-2b.id
  route_table_id = aws_route_table.rtb-pub.id
}

resource "aws_route_table_association" "pri-rtb-assoc-2a" {
  subnet_id = aws_subnet.pri-subnet-2a.id
  route_table_id = aws_default_route_table.rtb-pri.id
}
