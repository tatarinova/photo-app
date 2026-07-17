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
resource "aws_instance" "ec2_1" {

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [
                aws_security_group.ec2.id
                ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  key_name = data.aws_key_pair.existing.key_name

  user_data = file("${path.module}/user-data.sh")

  associate_public_ip_address = true

  monitoring = true  ### active metrics for CloudWatch

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-ec2-1"
    }
  )

}


resource "aws_instance" "ec2_2" {

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[1]

  vpc_security_group_ids = [
                aws_security_group.ec2.id
                ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  key_name = data.aws_key_pair.existing.key_name

  user_data = file("${path.module}/user-data.sh")

  associate_public_ip_address = true

  monitoring = true  ### active metrics for CloudWatch

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-ec2-2"
    }
  )

}