terraform {
  backend "s3" {
    bucket                  = "omarpiotr-bucket-ajc"
    key                     = "tp9.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "D:/10-TERRAFORM/.aws/credentials"
  }
}