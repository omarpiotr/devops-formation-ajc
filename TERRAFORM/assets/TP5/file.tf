resource "local_file" "ec2-parameters" {
  filename = "D:/10-TERRAFORM/TP5/ec2-parameters.txt"
  content  = "Pour cet EC2, nous avons utilisé le type d'instance ${aws_instance.myec2.instance_type} et l'image ${aws_instance.myec2.ami} "
}