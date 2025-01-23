provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "demo_sg" {
    name        = "demo_sg"
    description = "Allow ssh traffic"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "demoInstance" {
  ami = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  key_name = "login"
  security_groups = ["demo_sg"]
  tags = {
        Name = "demoInstance"
    }
}

