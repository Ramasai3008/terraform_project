provider "aws" {
  region = "us-east-1"
}


#NETWORKING
#=============

#------------------------------------------------------------------------------------------------

#VARIABLE_BLOCK
#================

#Variable_CIDR_Block
variable "vpc_cidr" {
  description = "cide_block for the VPC"
}

#Variable_VPC_Tag_Name
variable "vpc_name" {
  description = "tag_name for the VPC"
}

#Variable_Public_Subnet
variable "cidr_public_subnet" {
  description = "cidr_public_subnet for the VPC"
}

#Variable_Availability_Zone
variable "eu_availability_zone" {
  description = "Availability_Zone for the VPC"
}

#Variable_Private_Subnet
variable "cidr_private_subnet" {
  description = "cidr_private_subnet for the VPC"
}


#---------------------------------------------------------------------------------------------------------

#RESOURCE_BLOCK
#================

#Setup_CIDR_Block_(VPC)
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}


#Setup_Public_Subnet
resource "aws_subnet" "public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}


#Setup_Public_Subnet
resource "aws_subnet" "private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }
}


#Setup_Internet_Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Internet_Gateway"
  }
}


#Setup_Public_Route_Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "public_route_table"
  }
}

#Setup_Public_Route_Table_and_Public_Subnet_Association
resource "aws_route_table_association" "public_route_table_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


# Setup_Private_Route_Table, depends_on = [aws_nat_gateway.nat_gateway]
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "private-route_table"
  }
}


# Private Route Table and private Subnet Association
resource "aws_route_table_association" "private_route_table_subnet_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table
}

