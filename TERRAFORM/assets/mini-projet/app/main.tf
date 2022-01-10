module "deploy_sg" {
  source = "../modules/sg"
  sg_name = "omar-sg-miniprojet"
}

module "deploy_eip" {
  source = "../modules/eip"
  eip_tag_name = "omar-eip-miniprojet"
}

module "deploy_ebs" {
  source = "../modules/ebs"
  ebs_tag_name = "omar-ebs-miniprojet"
  zone_disponibilite = "us-east-1a"
  ebs_size = 1
}

module "deploy_ec2" {
  depends_on = [ module.deploy_eip ]
  source = "../modules/ec2"
  ami = data.aws_ami.app_ami.id
  instance_type = "t2.micro"
  key_name = "omar-kp-ajc"
  private_key_path = "D:/10-TERRAFORM/omar-kp-ajc.pem"
  username = "ubuntu"
  env = "prod"
  zone_disponibilite = "us-east-1a"
  sg_name = module.deploy_sg.sg_name
  static_ip = module.deploy_eip.eip_ip 
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = module.deploy_ebs.ebs_id
  instance_id = module.deploy_ec2.ec2_id
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.deploy_ec2.ec2_id
  allocation_id = module.deploy_eip.eip_id
}
