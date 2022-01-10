resource "aws_eip" "ec2_EIP" {
  vpc      = true

  tags = {
    Name      = var.eip_tag_name
    formation = "Frazer"
    iac       = "terraform"
  }
}
