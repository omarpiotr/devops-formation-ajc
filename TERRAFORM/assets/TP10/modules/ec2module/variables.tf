variable "ami" {
  default = "ami-04505e74c0741db8d"
  type    = string
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
    default = "omar-kp-ajc"
}

variable "sg_name" {
  default = "omar-sg-web"
}

variable "admin"{
    default = "omar"
}

variable "env" {
  default = "prod"
}