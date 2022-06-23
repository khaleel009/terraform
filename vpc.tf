// ***Working Terraform Code for VPC Creation***
// With 1 Public Subnet,1 Private Subnet,1 EIP,1 NAT,1 IGW,2 Route Table
// SecurityGroup.tf 

provider "aws" {
  region = "${var.region}"
  access_key = "AKIAXU54QTKNZ6YGYNGD"
  secret_key = "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"
}

// VPC Creation 
resource "aws_vpc" "myvpc" {
  cidr_block = "${var.vpcip}"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    "Name" = "myvpc"
  }
}

//Public Subnet Creation
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "${var.publicsubnetip}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "Public Subnet"
  }
}

//Private Subnet Creation 
resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "${var.privatesubnetip}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "Private Subnet"
  }
}

//IGW Creation and VPC Attachment
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myigw"
  }
}

//EIP Creation
resource "aws_eip" "eip" {
    vpc      = true
}

//NAT Gateway Creation
resource "aws_nat_gateway" "myngw" {
  allocation_id = aws_eip.eip.id 
  subnet_id     = aws_subnet.publicsubnet.id
  tags = {
    Name = "myngw"
  }
}

//Public RouteTable Creation and Edit Routes
resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.myigw.id 
    }
    tags = {
        Name = "publicrt"
    }
}

//Public Subnet Association
resource "aws_route_table_association" "publicrt" {
    subnet_id = aws_subnet.publicsubnet.id
    route_table_id = aws_route_table.publicrt.id

}

//Private Route table Creation
resource "aws_route_table" "privatert" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_nat_gateway.myngw.id
    }
    tags = {
        Name = "privatert"
    }
}

//Private Subnet Association and Edit Routes
resource "aws_route_table_association" "privatert" {
    subnet_id = aws_subnet.privatesubnet.id
    route_table_id = aws_route_table.privatert.id
}