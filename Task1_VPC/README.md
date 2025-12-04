Overview

This task focuses on designing and deploying a basic AWS network architecture using Terraform.
The setup includes a custom VPC, public and private subnets across multiple Availability Zones, an Internet Gateway for external access, and a NAT Gateway to provide secure outbound internet connectivity for private subnet resources.

Architecture Explanation

I created a custom VPC named Harshita_Khetan_VPC with CIDR block 10.0.0.0/16, which provides enough IP addresses for future scaling.
Inside the VPC, I designed two public and two private subnets spread across different Availability Zones for high availability.
An Internet Gateway (IGW) was attached to the VPC to allow public resources to access the internet.
A NAT Gateway was created inside one public subnet to allow private subnets to make outbound traffic (e.g., software updates) securely.
Two route tables (public & private) were configured to ensure correct routing for public-facing and internal resources.

CIDR Ranges Used & Why
Component	CIDR Block	Reason
VPC	10.0.0.0/16	Large IP range allowing many subnets and resources
Public Subnet 1	10.0.1.0/24	First AZ public range for scalable resources like ALB / EC2
Public Subnet 2	10.0.2.0/24	Second AZ public range for HA & redundancy
Private Subnet 1	10.0.3.0/24	Secure backend subnet for databases / internal EC2
Private Subnet 2	10.0.4.0/24	Second AZ backend subnet ensuring HA

4. Screenshots (Required for Submission)

Upload screenshots inside a folder named screenshots/ and reference them here:

VPC Screenshot – screenshots/vpc.png

Subnets Screenshot – screenshots/subnets.png

Route Tables Screenshot – screenshots/route_tables.png

IGW + NAT Gateway Screenshot – screenshots/nat_igw.png


Terraform Code

The complete Terraform code for this setup is in:

👉 main.tf file located in /Task1_VPC/main.tf

Terraform resources include:

VPC

2 Public Subnets

2 Private Subnets

Internet Gateway

NAT Gateway

Elastic IP for NAT

Public & Private Route Tables

Route Table Associations

How to Apply Terraform (Optional for Testing)
terraform init
terraform validate
terraform apply -auto-approve


To delete resources after submission:

terraform destroy -auto-approve

Notes

All resource names include the prefix Harshita_Khetan_ as required.

NAT Gateway is placed in Public Subnet 1 to allow outbound access for private resources.

Private subnets do NOT have direct internet access, improving security.
