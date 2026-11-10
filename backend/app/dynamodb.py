import boto3
from app.config import DYNAMODB_TABLE, AWS_REGION

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)

def save_photo_metadata(item: dict) -> None:
    """
    Save a new photo metadata item to DynamoDB
    """
    table.put_item(Item=item) 

def get_photo_metadata(photo_id: str) -> dict | None:
    """
    Retrieve photo metadata by ID
    """
    response = table.get_item(Key={"photo_id": photo_id}) 
    return response.get("Item") 

def list_all_photos_metadata() -> list:
    """
    Scan the table to retrieve all photo metadata
    """
    response = table.scan()
    return response.get("Items", [])

def delete_photo_metadata(photo_id: str) -> None:
    """
    Delete photo metadata entry from DynamoDB
    """
    table.delete_item(Key={"photo_id": photo_id})