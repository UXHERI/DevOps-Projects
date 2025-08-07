# Create a Key-Pair
resource "aws_key_pair" "wanderlust" {
  key_name = "wanderlust"
  public_key = file("wanderlust.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {
  
}

# Create a Security Group
resource "aws_security_group" "wanderlust-sg" {
  name = "wanderlust-sg"
  description = "This is the security group for wanderlust"
  vpc_id = aws_default_vpc.default.id

#Inbound Rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open HTTPS"
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Custom TCP"
  }

  ingress {
    from_port   = 465
    to_port     = 465
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open SMTPS"
  }

  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open SMTP"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Custom TCP"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow TCP on 30000-32767"
  }

  ingress {
    from_port   = 3000
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow TCP on 3000-10000"
  }

#Outbound Rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Access Open Outbound"
  }

#Tags for Security Group
  tags = {
    name = "wanderlust-sg"
  }
}

#Create an EC2 Instance
resource "aws_instance" "wanderlust_master" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.large"
  key_name = aws_key_pair.wanderlust.key_name
  security_groups = [aws_security_group.wanderlust-sg.name]
  tags = {
    Name = "wanderlust-Master"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}