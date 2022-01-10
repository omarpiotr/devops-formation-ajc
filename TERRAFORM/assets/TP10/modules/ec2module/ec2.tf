resource "aws_instance" "myec2" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.web-sg.name]
  
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
          user = "ubuntu"
          private_key = file("D:/10-TERRAFORM/omar-kp-ajc.pem")
          host = self.public_ip
      }
  }

}

resource "aws_security_group" "web-sg" {
  name = "omar-${var.env}-terr-web-sg"
  description = "Allow inbound traffic with port 22 & 80"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_eip" "OmarIP" {
  vpc      = true

  tags = {
    Name      = "omar-eip-Terraform"
    formation = "Frazer"
    iac       = "terraform"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.myec2.id
  allocation_id = aws_eip.OmarIP.id
}
