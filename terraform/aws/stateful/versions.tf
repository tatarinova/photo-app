# Terraform version and required providers

terraform {
  required_version = ">= 1.10"

  required_providers {

    # to create all AWS resources (AWS resource name starts with "aws_")
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}