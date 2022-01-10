variable "ebs_tag_name" {
  default = "omar-ebs-web"
}

variable "zone_disponibilite" {
  default = "us-east-1x"
}

variable "ebs_size" {
  default = 10
}

output "ebs_id" {
  value = aws_ebs_volume.ec2_EBS.id
}