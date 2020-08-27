provider "aws" {
  region = "me-south-1"
}

data "aws_ami" "latest_jenkins" {
  most_recent = true
  owners      = ["772816346052"]

  filter {
    name   = "name"
    values = ["beta-jenkins-machine-*"]
  }
}

resource "aws_key_pair" "beta" {
  key_name   = "beta-key"
  public_key = file("./ssh/id_rsa.pub")
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.latest_jenkins.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.steel.id]
  key_name               = aws_key_pair.beta.key_name

  tags = {
    Name = "beta-jenkins-server"
  }
}

resource "aws_security_group" "steel" {
  name = "jenkins-guard"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "jenkins" {
  value = aws_instance.jenkins.public_ip
}

