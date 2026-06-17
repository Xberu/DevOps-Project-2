variable "environment_name" {
  type = string
  description = "Name of the environment"
  default = "us-east-1"
}


variable "aws_region" {
  type = string
  description = "AWS region to deploy resources"
  default = "us-east-1"
}