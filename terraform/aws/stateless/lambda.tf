
# 1. IAM role for the lambda 
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

# 2. IAM policy for the lambda
resource "aws_iam_policy" "lambda_thumbnail_policy" {
  name        = "${local.resource_name}-lambda-thumbnail-policy"
  description = "Droits pour lire/ecrire dans S3 et maj DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # allow reading originals and writing thumbnails
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
        # allow DynamoDB table updates
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = data.terraform_remote_state.stateful.outputs.dynamodb_photo_metadata_arn
      },

      {
        # allow log creation (useful for debugging)
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

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_thumbnail_role.name
  policy_arn = aws_iam_policy.lambda_thumbnail_policy.arn
}


# 3. AWS Lambda function
resource "aws_lambda_function" "thumbnail_generator" {
  function_name = "${local.resource_name}-thumbnail-generator"
  role          = aws_iam_role.lambda_thumbnail_role.arn

  # ZIP file containing the Python script (gen_photo_miniatures.py) and dependencies (Pillow)
  filename         = "../../../lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("../../../lambda/lambda_function.zip")

  handler = "gen_photo_miniatures.lambda_handler" # Python file (gen_photo_miniatures) and handler function (lambda_handler)
  runtime = "python3.9"          # Python runtime version

  # Increase RAM and timeout for image processing (default : 128, 3 sec)
  memory_size = 512
  timeout     = 15

  # pass environment variables to the Python script
  environment {
    variables = {
      DYNAMODB_TABLE = data.terraform_remote_state.stateful.outputs.dynamodb_photo_metadata_name
      DESTINATION_PREFIX  = "miniatures/"
    }
  }
}


# 4. Allow S3 to invoke the Lambda
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.thumbnail_generator.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.terraform_remote_state.stateful.outputs.bucket_arn
}


# 5. S3 event notification trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.terraform_remote_state.stateful.outputs.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbnail_generator.arn
    events              = ["s3:ObjectCreated:*"]

    # anti-infinite loop security
    filter_prefix = "originals/"
    filter_suffix = ".jpg" # target only images
  }

  # Ensure permission is created (step 4) BEFORE configuring notification
  depends_on = [aws_lambda_permission.allow_bucket]
}