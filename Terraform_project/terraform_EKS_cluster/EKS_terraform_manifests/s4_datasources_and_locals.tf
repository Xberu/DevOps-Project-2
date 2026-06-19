
# Local values used throughout the EKS configuration
# Helps enforce naming consistency and reduce duplication

locals {
  # Business division or team name (from variable)
  owners = var.business_division  # Example: "retail_store"

  # Environment name such as dev, staging, prod (from variable)
  environment = var.environment_name  # Example: "dev"

  # Standardized naming prefix: "<division>-<env>"
  name = "${local.owners}-${local.environment}"  # Example: "retail_store-dev"

  # Full EKS cluster name used for resource naming and tagging
  eks_cluster_name = "${local.name}-${var.cluster_name}"  # Example: "retail_store-dev-eksdemo"
}