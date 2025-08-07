output "ec2_public_ip" {
  value = aws_instance.wanderlust_master.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.wanderlust_master.public_dns
}

output "ec2_private_ip" {
  value = aws_instance.wanderlust_master.private_ip
}