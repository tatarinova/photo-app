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


output "frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}