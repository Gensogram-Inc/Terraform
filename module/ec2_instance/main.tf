resource "aws_security_group" "gensogram1_sg" {
  name       = "gensogram_security_group"
  description = "Security group for gensogram server instance"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }


  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = var.terraform_sg
  }
}

resource "aws_instance" "gensogram1_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name      = "docker"
  vpc_security_group_ids = [aws_security_group.gensogram1_sg.id]

  tags = {
    Name = "Gerald-Instance"
  }
}
