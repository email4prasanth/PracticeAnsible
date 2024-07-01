# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "my_ami" {
  #   executable_users = ["self"]
  most_recent = true
  name_regex  = "^Packer-tut"
  owners      = ["610203850228"]
}
# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true #To display IPv4 DNS
  tags = {
    Name        = "${var.vpc_cidr_name}"
    environment = "${var.environment}"
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/2.56.0/docs/resources/security_group
resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.default.id
  ingress {
    description = "From internet to server"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "From Server VPC to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_all"
  }
}
############# Public Subnet, IGW, RT, RTAssociation, Server ##################
# https://registry.terraform.io/providers/hashicorp/aws/2.41.0/docs/resources/subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.public_subnet1_cidr_name}"
  }
}
# https://registry.terraform.io/providers/rgeraskin/aws2/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.IGW_name}"
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table.html
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.MainRT_name}"
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "RTA-pub" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.pub-rt.id
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "public-web-server-1" {
  availability_zone = "us-east-1a"
  # ami               = "ami-06beb07943797a85b"
  ami                         = data.aws_ami.my_ami.id
  instance_type               = "t2.micro"
  key_name                    = "DevOpsKey"
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true
  tags = {
    Name = "Public-Server-1"
  }
}
########## Private Subnet,Private EIP, NATGW, RT, RTAssociation, Server ############
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.private_subnet1_cidr_name}"
  }
}
resource "aws_eip" "nat-eip" {
  tags = {
    Name = "natgw-eip"
  }
}
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "NATgw"
  }
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_route_table" "pvt-rt1" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
    Name = "PvtRT_name"
  }
}
resource "aws_route_table_association" "RTA-pvt" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.pvt-rt1.id
}
resource "aws_instance" "private-web-server-1" {
  availability_zone = "us-east-1a"
  # ami               = "ami-06beb07943797a85b"
  ami                         = data.aws_ami.my_ami.id
  instance_type               = "t2.micro"
  key_name                    = "DevOpsKey"
  subnet_id                   = aws_subnet.private_subnet1.id
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = false
  tags = {
    Name = "Private-Server-1"
  }
  depends_on = [aws_nat_gateway.natgw]
}

