variable "ami" {
  default = "ami-04505e74c0741db8d"
  type    = string
}

variable "instance_type" {
  default = "t2.micro"
}

variable "zone_disponibilite" {
  default = "us-east-1x"
}

variable "key_name" {
    default = "omar-kp-ajc"
}

variable "sg_name" {
  default = "omar-sg-web"
}

variable "username"{
    default = "ubuntu"
}

variable "env" {
  default = "prod"
}

variable "private_key_path" {
  default = "D:/Formation/AJC/05.DevOps/omar-kp-ajc.pem"
}

variable "static_ip" {
  default = "0.0.0.0"
}

output "ec2_id" {
  value = aws_instance.myec2.id
}