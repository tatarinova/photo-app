##################################################
# Monitoring: SNS + CloudWatch Logs + Alarms
##################################################

resource "aws_sns_topic" "alerts" {
  name = "${local.resource_name}-alerts"
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

##################################################
# Log groups (ready for CloudWatch Agent later)
##################################################

resource "aws_cloudwatch_log_group" "user_data" {
  name              = "/${local.resource_name}/ec2/user-data"
  retention_in_days = 14
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/${local.resource_name}/app"
  retention_in_days = 14
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/${local.resource_name}/nginx"
  retention_in_days = 14
  tags              = local.common_tags
}

##################################################
# Give EC2 the permissions needed for CloudWatch Agent
##################################################

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

##################################################
# Alarm: ASG too small
##################################################

resource "aws_cloudwatch_metric_alarm" "asg_in_service_low" {
  alarm_name          = "${local.resource_name}-asg-in-service-low"
  alarm_description   = "Auto Scaling Group has too few instances in service"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Average"
  threshold           = 2
  treat_missing_data  = "breaching"

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupInServiceInstances"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.photo_app.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

##################################################
# Alarm: ALB unhealthy targets
##################################################

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${local.resource_name}-alb-unhealthy-hosts"
  alarm_description   = "ALB has unhealthy targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = aws_lb.photo_app.arn_suffix
    TargetGroup  = aws_lb_target_group.photo_app.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

##################################################
# Alarm: ALB target 5xx errors
##################################################

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  alarm_name          = "${local.resource_name}-alb-target-5xx"
  alarm_description   = "Targets are returning 5xx errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.photo_app.arn_suffix
    TargetGroup  = aws_lb_target_group.photo_app.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}