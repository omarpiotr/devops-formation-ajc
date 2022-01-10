variable "eip_tag_name" {
  default = "omar-eip-web"
}

output "eip_id" {
  value = aws_eip.ec2_EIP.id
}

output "eip_ip" {
  value = aws_eip.ec2_EIP.public_ip
}