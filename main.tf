terraform {
    required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "~>3.0"
        }
    }
}
provider "aws" {
    access_key = "AKIA5C6Q2GS735DLNWWH"
    secret_key = "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"
    region = "us-east-1"
}
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ssh_key"  
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_security_group" "aws-vm-sg" {
  name        = "vm-sg"
  description = "Allow incoming connections"
  vpc_id      = "vpc-021c3a437eafc6a0c"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }
}

resource "aws_instance" "vm-jenkins" {
  ami                    = "ami-04a0ae173da5807d3"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-060e736df5c41db6d"
  vpc_security_group_ids = [aws_security_group.aws-vm-sg.id]
  source_dest_check      = false
  key_name               = aws_key_pair.key_pair.key_name
  
  
  
  
  tags = {
    owner = "masters-of-destruction"
  }
}
