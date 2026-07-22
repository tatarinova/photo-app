##### ID AMI Ubuntu 24.04
data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}


#### Key pair : we use existing pem

data "aws_key_pair" "existing" {
  key_name = "photo-app-key"
}

#### EC2 
resource "aws_instance" "ec2" {

  for_each = local.ec2_instances

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[each.value.subnet_index]

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  key_name = data.aws_key_pair.existing.key_name

  user_data = templatefile("${path.module}/user-data.sh.tpl",
                                {
                                  aws_region          = var.aws_region
                                  config_bucket       = aws_s3_bucket.config.bucket

                                  frontend_repository = aws_ecr_repository.frontend.repository_url
                                  backend_repository  = aws_ecr_repository.backend.repository_url
                                }
                              )

  associate_public_ip_address = true

  monitoring = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-${each.key}"
    }
  )

}