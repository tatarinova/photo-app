locals {

  prefix = "${var.project_name}-${var.environment}" 

  resource_name = "${local.prefix}-tf"

  ### tf : to avoid confusion between resources created manually and those created by Terraform

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  ec2_instances = {
    ec2-1 = {
      subnet_index = 0
    }

    ec2-2 = {
      subnet_index = 1
    }

    
    # ec2-3 = {
    #   subnet_index = 2
    # }


  }


}


