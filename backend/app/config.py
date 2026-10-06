import os

AWS_REGION = os.getenv("AWS_REGION", "eu-west-3")
BUCKET_NAME = os.getenv("BUCKET_NAME")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE")
ADMIN_USERNAME = os.getenv("ADMIN_USERNAME")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD")