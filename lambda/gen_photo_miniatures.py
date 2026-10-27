'''
WARNING : if we modify this file --> regenerate and commit lambda_function.zip
'''

import os
import urllib.parse  ### encoding / decoding
import boto3
from PIL import Image # Python Pillow

# 1. Init des clients AWS en global
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# vars d'env definis dans le code Terraform (rf: lambda.tf)
TABLE_NAME = os.environ['DYNAMODB_TABLE']
DESTINATION_PREFIX = os.environ['DESTINATION_PREFIX'] # "miniatures/"

table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    """
    Fonction principale déclenchée automatiquement par un événement S3 (ObjectCreated)
    """
    try:
        # 2. Extract info from event S3
        record = event['Records'][0]
        bucket_name = record['s3']['bucket']['name']
        
        # Le nom du fichier dans S3 peut contenir des caractères encodés (ex: espaces remplacés par %20)
        raw_key = record['s3']['object']['key']
        source_key = urllib.parse.unquote_plus(raw_key, encoding='utf-8')
        
        print(f"Image reçue pour traitement : {source_key} dans le bucket {bucket_name}")

        # 3. Prepare temp files 
        file_name = os.path.basename(source_key)
        download_path = f"/tmp/{file_name}"
        upload_path = f"/tmp/thumb_{file_name}"

        # 4. Download original file from S3 in Lambda tmp/
        s3_client.download_file(bucket_name, source_key, download_path)

        # 5. Traitement de l'image avec Pillow (Resize)
        with Image.open(download_path) as img:

            # conserve original format (JPEG, PNG, etc.)
            img_format = img.format if img.format else "JPEG"
            
            # resize (ex: max 800x800 pixels)
            max_size = (800, 800)
            img.thumbnail(max_size)
            
            # save miniature
            img.save(upload_path, format=img_format, quality=85)

        # 6. clé de destination pour la miniature (ex: miniatures/mon_image.jpg)
        destination_key = f"{DESTINATION_PREFIX}{file_name}"

        # 7. Upload generated miniature 
        s3_client.upload_file(upload_path, bucket_name, destination_key)
        print(f"Miniature uploadée avec succès vers : {destination_key}")

        # 8. Get size of the miniature file [Bytes]
        file_size = os.path.getsize(upload_path)

        # 9. Write meta data in DynamoDB
        # On utilise le nom du fichier ou une clé unique comme identifiant
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
        print(f"Métadonnées enregistrées dans DynamoDB pour : {photo_id}")

        # clean up
        os.remove(download_path)
        os.remove(upload_path)

        return {
            "statusCode": 200,
            "body": f"Miniature créée et métadonnées enregistrées pour {file_name}"
        }

    except Exception as e:
        print(f"Erreur lors du traitement de la miniature : {str(e)}")
        raise e