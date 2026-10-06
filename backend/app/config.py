import os

AWS_REGION = os.getenv("AWS_REGION", "eu-west-3")
BUCKET_NAME = os.getenv("BUCKET_NAME")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE")