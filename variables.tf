variable "cidr_block" {
  description = "cidr block for vpc"
  default = "10.0.0.0/16"
  type = string
  
}

variable "cidr_subnet" {
  description = "cidr for subnet"
  default = "10.0.0.0/24"
  type = string
}

variable "cidr_rt" {
  description = "cidr range for subnet"
  default = "0.0.0.0/0"
  type = string
}

variable "cidr_sg" {
  description = "cidr range for SG"
  default = "0.0.0.0/0"
}

variable "ami_id" {
  description = "AMI_ID"
  type = string
  default = "ami-06aa3f7caf3a30282"
}

variable "instance_type" {
  description = "instance type"
  type = string
  default = "t2.micro"
}