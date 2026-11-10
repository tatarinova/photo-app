'''
WARNING : if you modify this file --> regenerate and commit lambda_function.zip
'''

import os
import urllib.parse  ### encoding / decoding
import boto3
from PIL import Image

# Initialize AWS clients globally
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# env vars defined in Terraform code (ref: lambda.tf)
TABLE_NAME = os.environ['DYNAMODB_TABLE']
DESTINATION_PREFIX = os.environ['DESTINATION_PREFIX'] # "miniatures/"

table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    """
    Main function triggered automatically by an S3 event (ObjectCreated)
    """
    try:
        # 1. Extract S3 event information
        record = event['Records'][0]
        bucket_name = record['s3']['bucket']['name']
        
        # decode potential URL-encoded characters in the S3 object key (e.g., spaces as %20)
        raw_key = record['s3']['object']['key']
        source_key = urllib.parse.unquote_plus(raw_key, encoding='utf-8')
        
        print(f"Processing image: {source_key} in bucket {bucket_name}")

        # 2. Prepare temporary paths 
        file_name = os.path.basename(source_key)
        download_path = f"/tmp/{file_name}"
        upload_path = f"/tmp/thumb_{file_name}"

        # 3. Download original file from S3 to Lambda temp storage 
        s3_client.download_file(bucket_name, source_key, download_path)

        # 4. Process image with Pillow (Resize)
        with Image.open(download_path) as img:

            # keep original format (JPEG, PNG, etc)
            img_format = img.format if img.format else "JPEG"
            
            # resize proportionally (max 800x800 pixels)
            max_size = (800, 800)
            img.thumbnail(max_size)
            
            # save thumbnail
            img.save(upload_path, format=img_format, quality=85)

        # 5. Build destination key for the thumbnail (miniatures/mon_image.jpg)
        destination_key = f"{DESTINATION_PREFIX}{file_name}"

        # 6. Upload generated thumbnail to S3 with dynamic content type 
        s3_client.upload_file(upload_path, bucket_name, destination_key, ExtraArgs={"ContentType": "image/jpeg"} )
        print(f"Thumbnail successfully uploaded to: {destination_key}")

        # 7. Get file size of the thumbnail in bytes
        file_size = os.path.getsize(upload_path)

        # 8. Write metadata to DynamoDB
        photo_id = file_name 
        
        table.put_item(
            Item={
                "photo_id": photo_id,
                "original_filename": file_name,
                "original_s3_key": source_key,
                "thumbnail_s3_key": destination_key,
                "file_size": file_size,
                "content_type": f"image/{img_format.lower()}",
                "upload_date": record['eventTime']
            }
        )
        print(f"Metadata saved in DynamoDB for: {photo_id}")

        # 9. Clean up temporary files
        os.remove(download_path)
        os.remove(upload_path)

        return {
            "statusCode": 200,
            "body": f"Thumbnail created and metadata saved for {file_name}"
        }

    except Exception as e:
        print(f"Error processing thumbnail: {str(e)}")
        raise e