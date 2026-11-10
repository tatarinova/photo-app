
import boto3
from botocore.config import Config
from app.config import BUCKET_NAME, AWS_REGION


s3_client = boto3.client(
                    "s3",
                    region_name=AWS_REGION,
                    config=Config(signature_version="s3v4"),
                )

def upload_file_to_s3(file_obj, s3_key: str, content_type: str) -> None:
    """
    Upload binary file to S3
    """
    s3_client.upload_fileobj(
        file_obj,
        BUCKET_NAME,
        s3_key,
        ExtraArgs={"ContentType": content_type}
    )

def generate_presigned_url(s3_key: str, expires_in: int = 3600) -> str:
    """
    Generate a temporary presigned URL for the photo
    """
    return s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": BUCKET_NAME, "Key": s3_key},
        ExpiresIn=expires_in,
    )

def delete_file_from_s3(s3_key: str) -> None:
    """
    Delete file from S3 bucket
    """
    s3_client.delete_object(Bucket=BUCKET_NAME, Key=s3_key)