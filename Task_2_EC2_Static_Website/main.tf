terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

# -- Security Group --
resource "aws_security_group" "FirstName_Lastname_web_sg" {
  name        = "Harshita_Khetan_Task2_web_sg"
  description = "Allow HTTP and SSH for Task2 - Harshita_Khetan"
  vpc_id      = var.vpc_id

  # Allow HTTP from anywhere (0.0.0.0/0)
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow SSH - recommended to restrict to your IP; default here is 0.0.0.0/0 for simplicity.
  # Replace var.ssh_allowed_cidr with your IP (e.g. "203.0.113.5/32")
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Harshita_Khetan_Task2_sg"
    Owner = "Harshita_Khetan"
    Project = "AWS_Assessment_Task2"
  }
}

# -- Get latest Amazon Linux 2023 AMI (x86_64) --
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# -- EC2 Instance --
resource "aws_instance" "FirstName_Lastname_resume_ec2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  associate_public_ip_address = true
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.FirstName_Lastname_web_sg.id]
  tags = {
    Name    = "Harshita_Khetan_Public_EC2"
    Owner   = "Harshita_Khetan"
    Project = "AWS_Assessment_Task2"
  }

  # user_data to install nginx and create an index.html resume
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx

              cat > /usr/share/nginx/html/index.html << 'HTML'
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="utf-8" />
                <title>Harshita Khetan Resume</title>
                <style>
                  body { font-family: Arial, sans-serif; margin: 40px; background:#f9f9f9; color:#333 }
                  h1 { color:#222 }
                  h2 { color:#555 }
                </style>
              </head>
              <body>
                <h1>Harshita Khetan</h1>
                <h2>Cloud & DevOps Engineer</h2>
                <p>Welcome to my resume website hosted on AWS EC2 using Nginx.</p>
                <hr>
                <h3>About Me</h3>
                <p>I am passionate about Cloud, AWS, DevOps and Automation.</p>
                <h3>Contact</h3>
                <p>Email: harshita.khetan@example.com</p>
              </body>
              </html>
              HTML
              EOF
}
