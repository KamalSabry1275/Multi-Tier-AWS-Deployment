output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "private_ip" {
  value = aws_instance.ec2.private_ip
}

output "ec2_sg_id" {
  value = aws_security_group.sg.id
}