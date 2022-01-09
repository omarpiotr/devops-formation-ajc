resource "aws_instance" "myec2_1" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = "${var.admin}-kp-ajc"
  security_groups = [aws_security_group.web-sg.name]
  user_data = "${file("install_nginx.sh")}"
  /*user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt-get install nginx -y
                systemctl enable nginx
                systemctl start nginx
                EOF
    */
  
  tags = {
    Name      = "${var.admin}-ec2-Terraform_01"
    formation = "Frazer"
    iac       = "terraform"
  }

  provisioner "local-exec" {
      command = "echo ${self.id} - ${self.public_ip} - ${self.availability_zone} >> infos_ec2.txt"
  }
}

resource "aws_instance" "myec2_2" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = "${var.admin}-kp-ajc"
  security_groups = [aws_security_group.web-sg.name]
  
  tags = {
    Name      = "${var.admin}-ec2-Terraform_02"
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

  provisioner "local-exec" {
      command = "echo ${self.id} - ${self.public_ip} - ${self.availability_zone} >> infos_ec2.txt"
  }
}



resource "aws_security_group" "web-sg" {
  name = "${var.admin}-terr-web-sg"
  description = "Allow inbound traffic with port 80 & 443"

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

  ingress {
    from_port   = 443
    to_port     = 443
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
