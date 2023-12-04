variable "region" {
  default = "eu-north-1"
}

variable "ami" {
  default = "ami-0416c18e75bd69567"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_pair" {
  default = "eshop-key"
}

variable "az_resource_group" {
  default = "eshop"
}

variable "az_location" {
  default = "eastus"
}
