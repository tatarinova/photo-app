resource "aws_lb_target_group" "photo_app" {

  name = "${local.resource_name}-tg"

  port = 80
  protocol = "HTTP"

  target_type = "instance"

  vpc_id = data.aws_vpc.default.id

  health_check {

    enabled = true

    path = "/api/health"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-tg"
    }
  )

}


#### atach the EC2 instances

resource "aws_lb_target_group_attachment" "ec2" {

  for_each = aws_instance.ec2

  target_group_arn = aws_lb_target_group.photo_app.arn

  target_id = each.value.id

  port = 80

}