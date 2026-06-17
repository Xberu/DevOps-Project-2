variable "aws_region" {
    description = "AWS region to deploy resources"
    type = string
    default = "us-east-1"
}
    
variable "environment_name" {
    description = "Name of the environment"
    type = string
    default = "dev"
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "172.20.0.0/16"
}

variable "tags" {
    description = "Global tags to apply to all resources"
    type = map(string)
    default = {
        Terraform = "true"
    }
}

variable "subnet_newbits" {
    description = "Number of new bits to use for subnetting"
    type = number
    default = 8
}