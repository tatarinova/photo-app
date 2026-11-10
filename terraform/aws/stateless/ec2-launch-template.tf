# AMI Ubuntu 24.04
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


# Existing key pair (use existing pem)
data "aws_key_pair" "existing" {
  key_name = "photo-app-key"
}


# Launch Template
resource "aws_launch_template" "photo_app" {
  name_prefix = "${local.resource_name}-lt-"

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.existing.key_name

  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # launch_template expects base64-encoded user data
  user_data = base64encode(templatefile("${path.module}/templates/user-data.sh.tpl", {
    aws_region          = var.aws_region
    config_bucket       = data.terraform_remote_state.stateful.outputs.config_bucket_name
    frontend_repository = data.terraform_remote_state.stateful.outputs.frontend_repository_url
    backend_repository  = data.terraform_remote_state.stateful.outputs.backend_repository_url
  }))

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.resource_name}-asg-instance"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}