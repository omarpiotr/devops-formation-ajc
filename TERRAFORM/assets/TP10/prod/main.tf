module "deploy_prod" {
  source = "../modules/ec2module"
  instance_type = "t2.micro"
  admin = "omar"
  env = "prod"
  ami = "ami-04505e74c0741db8d"
  key_name = "omar-sg-web"
}