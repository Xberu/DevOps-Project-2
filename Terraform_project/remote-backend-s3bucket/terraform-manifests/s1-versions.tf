terraform {
    required_version = ">= 1.15.6"
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = " ~> 6.50.0"
      }
      random = {
      source = "hashicorp/random"
      version = "~> 3.9.0"
        }
    }
# Remote backend configuration
# backend "s3" {
#   bucket = "tfstate-dev-us-east-1-r5cams"
#   key    = "lockfile/dev/terraform.tfstate"
#   region = "us-east-1"
#   encrypt = true
#   use_lockfile = true
# }
}

provider "aws" {
  region = var.aws_region
}