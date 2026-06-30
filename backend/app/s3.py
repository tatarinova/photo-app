import os

import boto3
from botocore.config import Config

BUCKET_NAME = os.environ["BUCKET_NAME"]

s3 = boto3.client(
                    "s3",
                    region_name="eu-west-3",
                    config=Config(signature_version="s3v4"),
                )