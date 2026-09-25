resource "aws_lb" "photo_app" {

  name = "${local.resource_name}-alb"

  load_balancer_type = "application"

  internal = false

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = data.aws_subnets.default.ids

  enable_deletion_protection = false

  idle_timeout = 60

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-alb"
    }
  )

}