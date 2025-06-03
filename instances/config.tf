terraform {
  backend "s3" {
    bucket = "ashvin-s3-clo835"            
    key    = "instances/terraform.tfstate"
    region = "us-east-1"                      
  }
}
