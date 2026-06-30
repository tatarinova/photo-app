import boto3
import os

BUCKET_NAME = os.environ["BUCKET_NAME"]

s3 = boto3.client("s3")