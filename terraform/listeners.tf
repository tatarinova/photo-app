data "aws_acm_certificate" "photo_app" {

  domain      = var.domain_name

  statuses    = ["ISSUED"]

  most_recent = true

}

#### Listener HTTP 80

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.photo_app.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "redirect"

    redirect {

      port = "443"

      protocol = "HTTPS"

      status_code = "HTTP_301"

    }

  }

}


### Listener HTTPS 443

resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.photo_app.arn

  port = 443

  protocol = "HTTPS"

  ### Security policy
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = data.aws_acm_certificate.photo_app.arn

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.photo_app.arn

  }

}
