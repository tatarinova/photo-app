##################################################
# Terraform version and required providers
##################################################

terraform {
  required_version = ">= 1.10"


  required_providers {

    # to create all AWS resources (resource "aws_..." ...)
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }

}