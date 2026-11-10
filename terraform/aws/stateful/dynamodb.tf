# DynamoDB table for photo metadata
resource "aws_dynamodb_table" "photo_metadata" {
  name         = "${local.resource_name}-photo-metadata"
  billing_mode = "PAY_PER_REQUEST" # Serverless billing mode (0 € if not used)
  hash_key     = "photo_id"

  attribute {
    name = "photo_id"
    type = "S" # String type
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-photo-metadata"
    }
  )
}