resource "aws_instance" "myec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "omar-kp-ajc"

  tags = {
    Name      = "omar-ec2-Terraform"
    formation = "Frazer"
    iac       = "terraform"
  }
}