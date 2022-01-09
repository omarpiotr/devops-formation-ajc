resource "aws_instance" "myec2" {
  ami             = data.aws_ami.app_ami.id
  instance_type   = var.instance_type
  key_name        = "${var.admin}-kp-ajc"
  security_groups = [aws_security_group.web-sg.name]

  tags = {
    Name      = "${var.admin}-ec2-Terraform"
    formation = "Frazer"
    iac       = "terraform"
  }
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning AMI (Amazon Linux 2)*"]
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
