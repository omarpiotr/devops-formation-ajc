resource "aws_instance" "myec2" {
  ami           = var.ami
  instance_type = data.local_file.info_ami.content
  key_name      = "omar-kp-ajc"

  tags = {
    Name      = "omar-ec2-Terraform"
    formation = "Frazer"
    iac       = "terraform"
  }
}

data "local_file" "info_ami"{
    filename = "./infos.txt"
}
