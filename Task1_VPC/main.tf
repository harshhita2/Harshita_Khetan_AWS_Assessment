terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "ap-south-1" # Mumbai region from your screenshots
}

# ---------------------------
# Config / Tag prefix
# ---------------------------
locals {
  prefix = "Harshita_Khetan"
  common_tags = {
    Project = "AWS_Assessment"
    Owner   = local.prefix
  }
}

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "${local.prefix}_VPC"
  })
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, {
    Name = "${local.prefix}_IGW"
  })
}

# ---------------------------
# Subnets - 2 public, 2 private
# ---------------------------
# Choose two AZs available in ap-south-1
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, { Name = "${local.prefix}_Public1" })
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, { Name = "${local.prefix}_Public2" })
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  tags = merge(local.common_tags, { Name = "${local.prefix}_Private1" })
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  tags = merge(local.common_tags, { Name = "${local.prefix}_Private2" })
}

# ---------------------------
# EIP for NAT Gateway
# ---------------------------
resource "aws_eip" "nat" {
  vpc = true
  tags = merge(local.common_tags, { Name = "${local.prefix}_NAT_EIP" })
}

# ---------------------------
# NAT Gateway (in public1)
# ---------------------------
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  tags = merge(local.common_tags, { Name = "${local.prefix}_NATGW" })
  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------
# Route Tables
# ---------------------------
# Public route table (internet via IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, { Name = "${local.prefix}_Public_RT" })
}

# Private route table (internet via NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = merge(local.common_tags, { Name = "${local.prefix}_Private_RT" })
}

# ---------------------------
# Route Table Associations
# ---------------------------
resource "aws_route_table_association" "pub1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "priv1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "priv2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------
# Outputs
# ---------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.natgw.id
}

output "nat_eip" {
  description = "NAT Gateway EIP (public IP)"
  value       = aws_eip.nat.public_ip
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}
