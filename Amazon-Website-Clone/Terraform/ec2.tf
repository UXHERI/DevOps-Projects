# Create a Key-Pair
resource "aws_key_pair" "devsecops" {
  key_name = "devsecops"
  public_key = file("devsecops.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {
  
}

# Create a Security Group
resource "aws_security_group" "devsecops-sg" {
  name = "devsecops-sg"
  description = "This is the security group for Amazon Clone DevSecOps + GitOps Project"
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SonarQube"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Node-Exporter"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana"
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
    name = "devsecops-sg"
  }
}

#Create an EC2 Instance
resource "aws_instance" "devsecops" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.large"
  key_name = aws_key_pair.devsecops.key_name
  security_groups = [aws_security_group.devsecops-sg.name]
  tags = {
    Name = "devsecops"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}
