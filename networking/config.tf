terraform {
  backend "s3" {
    bucket = "project-s3-clo835"            
    key    = "networking/terraform.tfstate"
    region = "us-east-1"                      
  }
}