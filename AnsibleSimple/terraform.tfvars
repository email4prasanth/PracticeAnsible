aws_region  = "us-east-1"
Key_name    = "DevOpsKey"
environment = "dev"

vpc_cidr             = "10.1.0.0/16" # pow(2,(32-16))= 65536 subnets
public_subnet1_cidr  = "10.1.1.0/24" # pow(2,(32-24))= 256 subnets
private_subnet1_cidr = "10.1.10.0/24"

vpc_cidr_name             = "Terrform-vpc"
public_subnet1_cidr_name  = "Terrform-PUB-1"
private_subnet1_cidr_name = "Terrform-PVT-1"
IGW_name                  = "Terraform-IGW"
MainRT_name               = "Terraform-MainRT"
# amis = ""                                                                                                                                                                                                                                                                                         
# azs = ""
# instance_type = ""