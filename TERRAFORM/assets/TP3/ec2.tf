resource "aws_instance" "myec2" {
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.micro"
    key_name = "omar-kp-ajc"

    tags = {
        Name = "omar-ec2-Terraform"
        formation = "Frazer"
        iac = "terraform"
    }
}