######## SG for EC2 (+ rules)
resource "aws_security_group" "ec2" {

  name = "${local.resource_name}-ec2-sg"

  description = "Security Group for EC2 instances"

  vpc_id = data.aws_vpc.default.id

  tags = local.common_tags
}


resource "aws_vpc_security_group_ingress_rule" "ec2_http" {

  security_group_id = aws_security_group.ec2.id

  ip_protocol = "tcp"

  from_port = 80

  to_port = 80

  referenced_security_group_id = aws_security_group.alb.id
}


resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {

  security_group_id = aws_security_group.ec2.id

  ip_protocol = "tcp"

  from_port = 22

  to_port = 22

  cidr_ipv4 = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "ec2_out" {

  security_group_id = aws_security_group.ec2.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}