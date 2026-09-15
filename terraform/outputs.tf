output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "bucket_name" {
  value = aws_s3_bucket.photos.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.photos.arn
}

output "config_bucket_name" {
  value = aws_s3_bucket.config.bucket
}


output "frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ami_ubuntu_noble_24_04" {
  value = data.aws_ami.ubuntu.id
}

output "aws_subnets_default" {
  value = data.aws_subnets.default.ids
}

output "ec2_instance_ids" {
  value = {
    for name, instance in aws_instance.ec2 :
    name => instance.id
  }
}

output "ec2_public_ips" {
  value = {
    for name, instance in aws_instance.ec2 :
    name => instance.public_ip
  }
}

output "ec2_private_ips" {
  value = {
    for name, instance in aws_instance.ec2 :
    name => instance.private_ip
  }
}

output "alb_dns_name" {
  value = aws_lb.photo_app.dns_name
}

output "alb_arn" {
  value = aws_lb.photo_app.arn
}

output "alb_url" {
  value = "https://${aws_lb.photo_app.dns_name}"
}