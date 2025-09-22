output "ec2_public_ip" {
  value = aws_instance.three-tier-eks.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.three-tier-eks.public_dns
}

output "ec2_private_ip" {
  value = aws_instance.three-tier-eks.private_ip
}
