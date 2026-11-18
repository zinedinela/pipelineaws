terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}
locals {
  subnets = {
    "eu-north-1a" = {
      public = "10.0.1.0/24"
      private = "10.0.10.0/24"
    }
    "eu-north-1b" = {
      public = "10.0.2.0/24"
      private = "10.0.11.0/24"
    }
  }
}    
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
for_each = local.subnets
availability_zone = each.key
vpc_id = aws_vpc.main.id
cidr_block = each.value.public
}
resource "aws_subnet" "private" {
for_each = local.subnets
availability_zone = each.key
vpc_id = aws_vpc.main.id
cidr_block = each.value.private
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
