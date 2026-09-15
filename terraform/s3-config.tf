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


# ####################################################
# # .env
# ####################################################

# resource "aws_s3_object" "env" {

#   bucket = aws_s3_bucket.config.id

#   key = ".env"

#   source = "${path.module}/../.env"

#   etag = filemd5("${path.module}/../.env")

# }