resource "aws_s3_bucket" "photos" {

    bucket = "${local.resource_name}-mafalda-photos"

    tags = local.common_tags
}


resource "aws_s3_bucket_public_access_block" "photos" {

  bucket = aws_s3_bucket.photos.id

  block_public_acls       = true

  block_public_policy     = true

  ignore_public_acls      = true

  restrict_public_buckets = true

}


resource "aws_s3_bucket_versioning" "photos" {

  bucket = aws_s3_bucket.photos.id

  versioning_configuration {

    status = "Enabled"

  }

}


resource "aws_s3_bucket_server_side_encryption_configuration" "photos" {

  bucket = aws_s3_bucket.photos.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }

  }

}
