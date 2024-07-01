variable "aws_region" {}
variable "Key_name" {}
variable "environment" {}
variable "vpc_cidr" {}

variable "public_subnet1_cidr" {}
variable "public_subnet2_cidr" {}
variable "public_subnet3_cidr" {}
variable "private_subnet1_cidr" {}
variable "private_subnet2_cidr" {}
variable "private_subnet3_cidr" {}

variable "vpc_cidr_name" {}
variable "public_subnet1_cidr_name" {}
variable "public_subnet2_cidr_name" {}
variable "public_subnet3_cidr_name" {}
variable "private_subnet1_cidr_name" {}
variable "IGW_name" {}
variable "MainRT_name" {}

# variable "amis" {
#   description = "AMI available in Region us-east-1"
#   default = {
#     us-east-1 = "ami-0e001c9271cf7f3b9" #Ubuntu Server 22.04 64-bit (x86)
#   }
# }
# variable "azs" {
#   description = "Availability Zone list"
#   default     = ["us-east-1a", "us-east-1b", "us-east-1c"] #list
# }
# variable "instance_type" {
#   description = "Required Instance type"
#   default = {
#     dev = "t2.micro"
#   }
# }
