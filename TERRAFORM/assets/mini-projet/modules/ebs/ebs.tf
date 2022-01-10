resource "aws_ebs_volume" "ec2_EBS" {
  availability_zone = var.zone_disponibilite
  size              = var.ebs_size

  tags = {
    Name = var.ebs_tag_name
    formation = "Frazer"
    iac       = "terraform"
  }
}