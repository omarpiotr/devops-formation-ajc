variable "sg_name" {
  default = "omar-sg-web"
}

output "sg_name" {
  value = aws_security_group.web-sg.name
}