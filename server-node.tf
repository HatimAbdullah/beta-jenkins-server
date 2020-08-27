provider "aws" {
  region = "me-south-1"
}

resource "aws_key_pair" "beta" {
  key_name   = "beta-key"
  public_key = file("./ssh/id_rsa.pub")
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0c5f01a87716073c6"
  instance_type          = "t3.micro"
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


output "jenkins-gateway" {
  value = aws_instance.jenkins.public_ip
}

