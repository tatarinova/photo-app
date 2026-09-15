##################################################
# Provider configuration
##################################################

provider "aws" {
  region = var.aws_region # toutes les resources seront creees dans cette region
}