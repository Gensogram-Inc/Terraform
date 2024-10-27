terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "gensogram_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name = "docker"

  tags = {
    Name = "Kunle-Instance"
  }
}