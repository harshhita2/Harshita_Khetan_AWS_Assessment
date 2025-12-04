📌 1. Overview

This project launches a Free-Tier EC2 instance in a public subnet, installs Nginx, and hosts a simple HTML-based resume website. The EC2 instance is accessible publicly on HTTP (port 80).

📌 2. Architecture Summary

EC2 instance: t3.micro (Free Tier eligible)

AMI: Amazon Linux 2023

Public Subnet: Provided from Task 1

Security Group:

Allow HTTP (80) from anywhere

Allow SSH (22) only from a specific IP (recommended)

Nginx is installed & configured via Terraform user_data

Resume HTML file placed in /usr/share/nginx/html/index.html

📌 3. Files Included
File	Description
main.tf	EC2 instance, security group, AMI, user_data (Nginx + resume)
variables.tf	Input variables such as subnet ID, VPC ID, key pair
outputs.tf	Displays Instance ID, Public IP, and Public DNS
terraform.tfvars (optional)	Stores your variable values
README.md	Documentation of setup and deployment steps
📌 4. How to Use the Terraform Code
Step 1: Update Variables

You must provide:

vpc_id

subnet_id (public subnet)

key_name (existing EC2 key pair)

ssh_allowed_cidr (your IP for SSH)

Either edit terraform.tfvars:

vpc_id            = "vpc-xxxxxx"
subnet_id         = "subnet-xxxxxx"
key_name          = "HarshitaKP"
ssh_allowed_cidr  = "YOUR_PUBLIC_IP/32"

Step 2: Initialize Terraform
terraform init

Step 3: Deploy EC2 Instance
terraform apply -auto-approve


After deployment, Terraform will output:

Public IP

Public DNS

Open the site:

http://<public-ip>/

📌 5. Nginx User Data Script (Automatically Applied)

Terraform installs and configures Nginx, then writes your resume page:

yum update -y
yum install nginx -y
systemctl enable nginx
systemctl start nginx


Your resume HTML file is created automatically inside the EC2 instance.

📌 6. AWS Best Practices Applied

✔ Security Group restricted for SSH
✔ Minimal ports exposed (only 22 & 80)
✔ User-data used for automated provisioning
✔ Tags added for tracking resources

📌 7. Cleanup

To avoid charges, destroy resources when finished:

terraform destroy -auto-approve

📌 8. Output Example
instance_id = "i-0123abcd4567ef890"
public_ip   = "65.xx.yy.zz"
public_dns  = "ec2-65-xx-yy-zz.ap-south-1.compute.amazonaws.com"
