# Create a Key-Pair
resource "aws_key_pair" "hotstar" {
  key_name = "hotstar"
  public_key = file("hotstar.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {
  
}

# Create a Security Group
resource "aws_security_group" "hotstar-sg" {
  name = "hotstar-sg"
  description = "This is the security group for Hotstar Project"
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
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SonarQube"
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
    name = "hotstar-sg"
  }
}

#Create an EC2 Instance
resource "aws_instance" "hotstar" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.large"
  key_name = aws_key_pair.hotstar.key_name
  security_groups = [aws_security_group.hotstar-sg.name]
  tags = {
    Name = "hotstar"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}