import boto3
from app.config import DYNAMODB_TABLE, AWS_REGION

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)

def save_photo_metadata(item: dict):
    """Insère un nouvel élément dans DynamoDB"""
    table.put_item(Item=item) 

def get_photo_metadata(photo_id: str) -> dict:
    """Récupère les métadonnées d'une photo par son ID[cite: 2]"""
    response = table.get_item(Key={"photo_id": photo_id}) 
    return response.get("Item") 

def list_all_photos_metadata() -> list:
    """Scanne la table pour récupérer la liste de toutes les photos"""
    response = table.scan()
    return response.get("Items", [])

def delete_photo_metadata(photo_id: str):
    """Supprime l'entrée des métadonnées dans DynamoDB"""
    table.delete_item(Key={"photo_id": photo_id})