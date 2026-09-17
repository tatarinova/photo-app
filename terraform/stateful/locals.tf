locals {

  prefix = "${var.project_name}-${var.environment}"

  resource_name = "${local.prefix}-tf"

  ### tf : to avoid confusion between resources created manually and those created by Terraform

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

}


