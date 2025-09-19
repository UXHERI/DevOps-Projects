output "ec2_public_ip" {
  value = aws_instance.hotstar.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.hotstar.public_dns
}

output "ec2_private_ip" {
  value = aws_instance.hotstar.private_ip
}