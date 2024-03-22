/***************************
*     create vpc          *
***************************/

resource "aws_vpc" "three-tier-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    terraform = "true"
    Name      = "three tier vpc"
  }
}

/***************************
*     public subnet         *
***************************/

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public subnet eu-west-2a"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public subnet eu-west-2b"
  }
}

/***************************
*     private subnet         *
***************************/

resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private subnet eu-west-2a"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private subnet eu-west-2b"
  }
}

/***************************
*    database private subnet         *
***************************/

resource "aws_subnet" "private-subnet-3" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "db private subnet eu-west-2a"
  }
}

resource "aws_subnet" "private-subnet-4" {
  vpc_id            = aws_vpc.three-tier-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "db private subnet eu-west-2b"
  }
}

/***********************************************
*           internet gateway                   *
************************************************/

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.three-tier-vpc.id

  tags = {
    Name = "vpc internet gateway"
  }
}

/***********************************************
*           route table                        *
************************************************/

resource "aws_route_table" "web-route-table" {
  vpc_id = aws_vpc.three-tier-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

/***********************************************
*           route table association            *
************************************************/

resource "aws_route_table_association" "public-sn1-2a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.web-route-table.id
}

/***********************************************
*           route table association            *
************************************************/

resource "aws_route_table_association" "public-sn2-2b" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.web-route-table.id
}

