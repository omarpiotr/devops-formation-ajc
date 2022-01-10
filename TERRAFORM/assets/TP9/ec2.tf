resource "aws_instance" "ansible_master" {
  depends_on = [
    aws_instance.ansible_worker
  ]
  ami             = var.ami
  instance_type   = "t3.medium"
  key_name        = "${var.admin}-kp-ajc"
  security_groups = [aws_security_group.web-sg.name]

  tags = {
    Name      = "${var.admin}-ec2-Terraform_Master"
    formation = "Frazer"
    iac       = "terraform"
  }

  provisioner "local-exec" {
    command = "echo Ansible Master : ${self.id} - ${self.public_ip} - ${self.availability_zone} >> infos_ec2.txt"
  }

  provisioner "file" {
    source      = "D:/10-TERRAFORM/omar-kp-ajc.pem"
    destination = "/home/ubuntu/.ssh/omar-kp-ajc.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("D:/10-TERRAFORM/omar-kp-ajc.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 15",
      "sudo apt-get update -y",
      "sleep 5",
      "chmod 400 /home/ubuntu/.ssh/omar-kp-ajc.pem",
      "sudo apt-get install ansible -y",
      "sudo apt-get install sshpass -y",
      "mkdir ansible-deploy",
      "git clone https://github.com/omarpiotr/ansible-deploy-wordpress.git ./ansible-deploy",
      "cd ./ansible-deploy",
      "ansible-galaxy install -r roles/requirements.yml",
      "ansible-playbook -i hosts.yml playbook.yml -e ansible_connection='ssh' -e ansible_host='${aws_instance.ansible_worker.public_ip}' --private-key '/home/ubuntu/.ssh/omar-kp-ajc.pem'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("D:/10-TERRAFORM/omar-kp-ajc.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "ansible_worker" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = "${var.admin}-kp-ajc"
  security_groups = [aws_security_group.web-sg.name]

  tags = {
    Name      = "${var.admin}-ec2-Terraform_worker"
    formation = "Frazer"
    iac       = "terraform"
  }

  provisioner "local-exec" {
    command = "echo Worker : ${self.id} - ${self.public_ip} - ${self.availability_zone} >> infos_ec2.txt"
  }
}


resource "aws_security_group" "web-sg" {
  name        = "${var.admin}-terr-web-sg"
  description = "Allow inbound traffic with port 22 & 80"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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
