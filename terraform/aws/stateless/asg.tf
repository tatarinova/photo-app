##################################################
# Auto Scaling Group
##################################################

resource "aws_autoscaling_group" "photo_app" {
  name = "${local.resource_name}-asg"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = local.sorted_subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.photo_app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.resource_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
  ]

  metrics_granularity = "1Minute"


}

##################################################
# Attach ASG to Target Group
##################################################

resource "aws_autoscaling_attachment" "photo_app" {
  autoscaling_group_name = aws_autoscaling_group.photo_app.id
  lb_target_group_arn    = aws_lb_target_group.photo_app.arn
}