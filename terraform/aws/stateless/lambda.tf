# ------------------------------------------------------------------------------
# 1. RÔLE IAM POUR LA LAMBDA 
# ------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_thumbnail_role" {
  name = "${local.resource_name}-lambda-thumbnail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 2. PERMISSIONS POUR LA LAMBDA
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "lambda_thumbnail_policy" {
  name        = "${local.resource_name}-lambda-thumbnail-policy"
  description = "Droits pour lire/ecrire dans S3 et maj DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Autoriser la lecture dans le dossier des originaux et l'écriture dans miniatures
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${data.terraform_remote_state.stateful.outputs.bucket_arn}/originals/*",
          "${data.terraform_remote_state.stateful.outputs.bucket_arn}/miniatures/*",
        ]
      },
      {
        # Autoriser la mise à jour de la table DynamoDB
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem"
        ]
        Resource = data.terraform_remote_state.stateful.outputs.dynamodb_photo_metadata_arn
      },
      {
        # Autoriser la création de logs (utile pour debug)
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attacher la politique au rôle
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_thumbnail_role.name
  policy_arn = aws_iam_policy.lambda_thumbnail_policy.arn
}

# ------------------------------------------------------------------------------
# 3. LA FONCTION AWS LAMBDA
# ------------------------------------------------------------------------------
resource "aws_lambda_function" "thumbnail_generator" {
  function_name = "${local.resource_name}-thumbnail-generator"
  role          = aws_iam_role.lambda_thumbnail_role.arn

  # Le fichier ZIP contenant le script Python (xxxxx.py) et les librairies (Pillow)
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  handler = "xxxxx.lambda_handler" # Nom du fichier Python (xxxxx) . Nom de la fonction (lambda_handler)
  runtime = "python3.9"          # Version de Python

  # Pour le traitement d'image on augmente la RAM et le timeout (default : 128, 3 sec)
  memory_size = 512
  timeout     = 15

  # on passe les variables d'env au script Python
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = data.terraform_remote_state.stateful.outputs.dynamodb_photo_metadata_name
      DESTINATION_PREFIX  = "miniatures/"
    }
  }
}

# ------------------------------------------------------------------------------
# 4. AUTORISER S3 À INVOQUER LA LAMBDA
# ------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.thumbnail_generator.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.terraform_remote_state.stateful.outputs.bucket_arn
}

# ------------------------------------------------------------------------------
# 5. LE DÉCLENCHEUR S3 (EVENT NOTIFICATION)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.terraform_remote_state.stateful.outputs.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbnail_generator.arn
    events              = ["s3:ObjectCreated:*"]

    # LA SÉCURITÉ ANTI-BOUCLE INFINIE :
    filter_prefix = "originals/"
    filter_suffix = ".jpg" # cibler seuelement les images
  }

  # Terraform doit créer l'autorisation (bloc 4) AVANT de configurer la notification
  depends_on = [aws_lambda_permission.allow_bucket]
}