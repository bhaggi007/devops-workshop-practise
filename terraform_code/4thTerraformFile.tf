provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "dpp-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "dpp-vpc"
    }
}

resource "aws_subnet" "dpp-vpc-subnet01" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = { 
    Name = "dpp-vpc-subnet01"
   }
}

resource "aws_subnet" "dpp-vpc-subnet02" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = { 
    Name = "dpp-vpc-subnet02"
   }
}

resource "aws_internet_gateway" "dpp-igw" {
  vpc_id = aws_vpc.dpp-vpc.id
  tags = {
    Name = "dpp-igw"
  }
}

resource "aws_route_table" "dpp-route-table" {
  vpc_id = aws_vpc.dpp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpp-igw.id
    }
}

resource "aws_route_table_association" "dpp-rta-subnet-01" {
  subnet_id = aws_subnet.dpp-vpc-subnet01.id
  route_table_id = aws_route_table.dpp-route-table.id

}
resource "aws_route_table_association" "dpp-rta-subnet-02" {
  subnet_id = aws_subnet.dpp-vpc-subnet02.id
  route_table_id = aws_route_table.dpp-route-table.id
}

resource "aws_instance" "dpp-instance" {
  ami = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  key_name = "login"
  subnet_id = aws_subnet.dpp-vpc-subnet01.id
  vpc_security_group_ids = [aws_security_group.dpp-securitygroup-ssh.id]
  for_each = toset(["jenkins-master", "build-slave","ansible-server"])
   tags = {
     Name = "${each.key}"
   }
}

resource "aws_security_group" "dpp-securitygroup-ssh" {
  vpc_id = aws_vpc.dpp-vpc.id
  name = "dpp-securitygroup-ssh"
    ingress {
        description = "Allow ssh traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}