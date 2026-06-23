#!/bin/bash
set -e

echo "Creating vpc  with Terraform..."
echo"==============================="

cd VPC_terraform_manifests
terraform init
terraform apply -auto-approve

echo "VPC created successfully!"
echo"==============================="

echo "creating EKS cluster with Terraform..."
echo"==============================="

cd ../EKS_terraform_manifests
terraform init
terraform apply -auto-approve

echo "EKS cluster created successfully!"
echo"==============================="