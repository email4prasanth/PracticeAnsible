#### Choose available Packer AMI (use regular expression & most recent) and deploy a public web server and private webserver 
- Required variables and assign 
  1. Existing resource in aws
    - aws_region
    - Key_name
    - environment
  2. Where to launch and with which name is completely user wish and it should be relative
    - vpc_cidr
    - public_subnet1_cidr
    - private_subnet_cidr
    - vpc_cidr_name (any-name)
    - public_subnet1_cidr_name (any-name)
    - private_subnet_cidr_name (any-name)
    - IGW_name (any-name)
    - MainRT (any-name)
    
  3. Optional
    - amis
    - azs
    - instance_type

    
- Argument - (input) Value given to method/function as its parameter.
- Attribute - (getting output) Variables decleared outside a method in a class.
#### variable syntax and should save as terraform.tfvars
aws_region = "us-east-1"

#### variable name and should save as variables.tf
variable "aws_region" {}

#### Resource and data required in main.tf and its dependency provide tags for all resources
0. Basic Requirements Terrafrom Version, provider, ami, vpc, sg
  - terraform {
    required_version (Forcing version)
    required_providers {
      aws = {}
    }
  }
  - provider "aws" {} - aws_region
  - data "aws_ami" "my_ami" {} - owner, regex, recent
  - resource "aws_vpc" "default" {} - vpc_cidr, vpc_name, environment (vpc_id is used in the bellow resource)
- resource "aws_security_group" "allow_all" {} - ingress, egress

1. Public 
  - resource "aws_subnet" "subnet1-public" {} - public_subnet1_cidr, az 
  - resource "aws_internet_gateway" "default" {} - IGW_name
  - resource "aws_route_table" "terraform-public" {} - route (igw,allow all) 
  - resource "aws_route_table_association" "terraform-public" {} - public_subnetid, pubrtid
  - resource "aws_instance" "public-web-1" {}

2. Private
  - resource "aws_subnet" "subnet2-private" {} - private_subnet2_cidr, az 
  - resource "aws_eip" "nat-eip" {}
  - resource "aws_nat_gateway" "natgw" {} -nat-eip, public_subnet1, depends_on igw
  - resource "aws_route_table" "pvt-rt1" {} -route (nat,allow all)
  - resource "aws_route_table_association" "RTA-pvt" {} - private_subnet1id, pvtrtid
  - resource "aws_instance" "private-web-1" {}

- Using the above resource and data created terraform file (terrafrom.tfvars, variables.tf, main.tf) and run the following command
```
terraform init (This will create a lock file .terraform.lock.hcl)
terraform fmt
terraform validate
terraform plan
terraform apply --auto-approve
terraform destroy --auto-approve
```
- Packer build AMI, it is one module
- Terraform is used to automate the following figure the above resources are required
![Terraform-1]()
  1. 


# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {}
  }
}
provider "azurerm" {}
resource "azurerm_resource_group" "example" {}
resource "azurerm_virtual_network" "example" {}