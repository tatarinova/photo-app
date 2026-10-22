
output "bucket_name" {
  value = aws_s3_bucket.photos.bucket
  # or : 
  # value = aws_s3_bucket.photos.id 
  # .id et .bucket is bucket name
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

output "dynamodb_photo_metadata_arn"{
  value = aws_dynamodb_table.photo_metadata.arn
}

output "dynamodb_photo_metadata_name"{
  value = aws_dynamodb_table.photo_metadata.name
}
