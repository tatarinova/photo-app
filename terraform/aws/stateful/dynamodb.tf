####################################################
### Table DynamoDB - Métadonnées des photos
####################################################

resource "aws_dynamodb_table" "photo_metadata" {
  name         = "${local.resource_name}-photo-metadata"
  billing_mode = "PAY_PER_REQUEST" # Mode Serverless (0 € si inutilisé)
  hash_key     = "photo_id"

  attribute {
    name = "photo_id"
    type = "S" # S = String (Chaîne de caractères)
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-photo-metadata"
    }
  )
}