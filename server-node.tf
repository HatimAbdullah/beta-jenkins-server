provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "copper" {
  key_name   = "kingdom-key"
  public_key =  file("./ssh/id_rsa.pub")
}

resource "aws_route53_zone" "jzone" {
  name = "cicd"

  vpc {
    vpc_id = aws_vpc.jvpc.id
  }

}

resource "aws_vpc" "jvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "jsubnet" {
  vpc_id                  = aws_vpc.jvpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "jgateway" {
  vpc_id = aws_vpc.jvpc.id
}

resource "aws_route" "ocean_internet_access" {
  route_table_id         = aws_vpc.jvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.jgateway.id
}


resource "aws_route53_record" "jenkins-end" {
  zone_id = aws_route53_zone.jzone.id
  name    = "jenkins"
  type    = "A"
  ttl     = "300"

  records = [aws_instance.jenkins.private_ip]
}

resource "aws_instance" "jenkins" {
  ami           = "ami-02148876501861cde"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.steel.id]
  key_name = aws_key_pair.copper.key_name
  subnet_id              = aws_subnet.jsubnet.id

  tags = {
    Name = "jenkins-server"
}
}

resource "aws_instance" "bastion" {
  instance_type          = "t3.micro"
  ami                    = "ami-051274f257aba97f9"
  key_name               = aws_key_pair.copper.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.jsubnet.id

  tags = {
    Name = "jenkins-bastion"
  }

}


resource "aws_security_group" "steel" {
  name = "jenkins-guard"
  vpc_id = aws_vpc.jvpc.id

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    security_groups = [aws_security_group.bastion.id]

  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Security Group for the masses"
  vpc_id = aws_vpc.jvpc.id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]

  }
}

output "jenkins-gateway" {
  value = aws_instance.bastion.public_ip
}

