data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {

  filter {

    name = "vpc-id"

    values = [data.aws_vpc.default.id]

  }

}

data "terraform_remote_state" "stateful" {
  backend = "local" 
  config = {
    path = "../stateful/terraform.tfstate"
  }
}