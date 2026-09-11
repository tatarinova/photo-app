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

# 1) 
# create LOCAL docker-compose.yml from template file (docker-compose.yml.tpl)
# in generated/
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
#### L'etape 1 n'est pas obligatoire
#### On peut generer docker-compose.yml directement en memoire et l'envoyer dans S3



# 2) upload to the s3 bucket (s3-config)

resource "aws_s3_object" "docker_compose" {

  #bucket = aws_s3_bucket.config.id

  ### /!\ For S3 bucket : id = bucket
  bucket = aws_s3_bucket.config.bucket  

  key = "docker-compose.yml"

  source = local_file.docker_compose.filename

  # Re-upload the object only if the generated file changes
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