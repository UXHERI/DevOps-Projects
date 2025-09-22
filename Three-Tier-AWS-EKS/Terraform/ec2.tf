# Create a Key-Pair
resource "aws_key_pair" "three-tier-eks" {
  key_name = "three-tier-eks"
  public_key = file("three-tier-eks.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {
  
}

# Create a Security Group
resource "aws_security_group" "three-tier-eks-sg" {
  name = "three-tier-eks-sg"
  description = "This is the security group for Three Tier EKS with ArgoCD Project"
  vpc_id = aws_default_vpc.default.id

#Inbound Rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open HTTP"
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
    name = "three-tier-eks-sg"
  }
}

#Create an EC2 Instance
resource "aws_instance" "three-tier-eks" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.small"
  key_name = aws_key_pair.three-tier-eks.key_name
  security_groups = [aws_security_group.three-tier-eks-sg.name]
  tags = {
    Name = "three-tier-eks"
  }
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
}
