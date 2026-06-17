# Terraform Block
terraform {
 required_version = ">= 1.15.6" 
 required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " ~> 6.50.0"
    }
     random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}

# provider Block
provider "aws" {
  region = "us-east-1"
}