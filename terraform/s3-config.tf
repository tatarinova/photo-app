####################################################
# Config bucket
####################################################

resource "aws_s3_bucket" "config" {

  bucket = "${local.resource_name}-config"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-config"
    }
  )

}

####################################################
# Block public access
####################################################

resource "aws_s3_bucket_public_access_block" "config" {

  bucket = aws_s3_bucket.config.id

  block_public_acls       = true

  block_public_policy     = true

  ignore_public_acls      = true

  restrict_public_buckets = true

}

####################################################
# Versioning
####################################################

resource "aws_s3_bucket_versioning" "config" {

  bucket = aws_s3_bucket.config.id

  versioning_configuration {

    status = "Enabled"

  }

}

####################################################
# docker-compose.yml
####################################################

# create docker-compose.yml from template file (docker-compose.yml.tpl)
resource "local_file" "docker_compose" {
  # generate interraform/generated
  filename = "${path.module}/generated/docker-compose.yml"

  # template
  content = templatefile("${path.module}/templates/docker-compose.yml.tpl", {
    backend_repository  = aws_ecr_repository.backend.repository_url
    frontend_repository = aws_ecr_repository.frontend.repository_url
    photos_bucket       = aws_s3_bucket.photos.bucket
  })
}

resource "aws_s3_object" "docker_compose" {

  bucket = aws_s3_bucket.config.id

  key = "docker-compose.yml"

  source = local_file.docker_compose.filename

  # hash MD5 of generated file
  etag = filemd5(local_file.docker_compose.filename)

}

####################################################
# .env
####################################################

resource "aws_s3_object" "env" {

  bucket = aws_s3_bucket.config.id

  key = ".env"

  source = "${path.module}/../.env"

  etag = filemd5("${path.module}/../.env")

}