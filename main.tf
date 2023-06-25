terraform {
    required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "~>3.0"
        }
    }
}
provider "aws" {
    access_key = "AKIA6JRAYFWTJD47ZTSI"
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
  vpc_id      = "vpc-0719811f271e323fd"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }
}

resource "aws_instance" "KWorker2" {
  ami                    = "ami-04a0ae173da5807d3"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-093b33ca6d815c5a5"
  vpc_security_group_ids = [aws_security_group.aws-vm-sg.id]
  source_dest_check      = false
  key_name               = aws_key_pair.key_pair.key_name
  
  tags = {
    Owner = "GEC Microservices"
    Name  = "KWorker-2"
  }
}


resource "aws_instance" "KMaster" {
  ami                    = "ami-04a0ae173da5807d3"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-093b33ca6d815c5a5"
  vpc_security_group_ids = [aws_security_group.aws-vm-sg.id]
  source_dest_check      = false
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    owner = "GEC Microservices"
    Name  = "vm-jenkins"
  }
}
resource "aws_instance" "KWorker-1" {
  ami                    = "ami-04a0ae173da5807d3"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-093b33ca6d815c5a5"
  vpc_security_group_ids = [aws_security_group.aws-vm-sg.id]
  source_dest_check      = false
  key_name               = aws_key_pair.key_pair.key_name

  tags = {
    owner = "GEC Microservices"
    Name  = "KWorker-1"
  }
}

resource "aws_efs_file_system"  "data-k8s"{
  creation_token = "data-k8s"
  encrypted = true
  tags = {
    Owner = "GEC Microservices"
    Name  = "data_K8s"
  }
}

resource "aws_vpc" "vpc_master" {
  cidr_block		= "192.168.0.0/16"
  enable_dns_support	= true
  enable_dns_hostnames	= true
  tags = {
    Name = "VPC-GEC-K8S"
    Owner = "GEC Microservices"
  }
}

#resource "aws_instance" "ec2-virtual-machine" {
# ami                         = ami-12345
# instance_type               = t2.micro
# key_name                    = aws_key_pair.master-key.key_name
# associate_public_ip_address = true
# vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
# subnet_id                   = aws_subnet.subnet.id
# provisioner "local-exec" {
#   command = "aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id}"
#  }
#}
