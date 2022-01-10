module "deploy_dev" {
  source = "../modules/ec2module"
  instance_type = "t2.nano"
  admin = "omar"
  env = "dev"
  ami = "ami-04505e74c0741db8d"
  key_name = "omar-sg-web"
}