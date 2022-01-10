resource "aws_instance" "myec2" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.sg_name]
  availability_zone = var.zone_disponibilite
  
  tags = {
    Name      = "ec2-${var.env}-omar"
    formation = "Frazer"
    iac       = "terraform"
  }

  provisioner "remote-exec" {
      inline = [
        "sudo apt-get update -y",
        "sudo apt-get install nginx -y",
        "sudo systemctl enable nginx",
        "sudo systemctl start nginx"
      ]

      connection {
          type = "ssh"
          user = var.username
          private_key = file("${var.private_key_path}")
          host = self.public_ip
      }
  }

  provisioner "local-exec" {
      command = "echo IP public par défaut :${self.public_ip} - IP static depuis EIP :${var.static_ip} >> ip_ec2.txt"
  }

}