provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# Pull outputs from networking module in S3
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "project-s3-clo835"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "my_key" {
  key_name   = "clo835_key"
  public_key = file("${path.module}/clo835_key.pub")
}


# Create ECR Repositories
resource "aws_ecr_repository" "webapp" {
  name = "webapp"
}

resource "aws_ecr_repository" "mysql" {
  name = "mysql"
}


# Security Group for EC2 instance
resource "aws_security_group" "allow_traffic" {
  name        = "webapp-sg"
  description = "Allow SSH and app ports"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "clo835-sg"
  }
}


# EC2 Instance to run Docker containers
resource "aws_instance" "webapp_instance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.allow_traffic.id]

  tags = {
    Name = "clo835-instance"
  }
}
