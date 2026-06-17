# Data Block
data "aws_availability_zones" "available" {
  state = "available"
  region = var.aws_region
}

# Local Block
locals {
    azs = slice(data.aws_availability_zones.available.names, 0, 3)

    public_subnet = [
        for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)
    ]

    private_subnet = [
        for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)
    ]
}