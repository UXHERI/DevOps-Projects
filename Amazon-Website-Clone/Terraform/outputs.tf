output "ec2_public_ip" {
  value = aws_instance.devsecops.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.devsecops.public_dns
}

output "ec2_private_ip" {
  value = aws_instance.devsecops.private_ip
}
