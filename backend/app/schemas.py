from pydantic import BaseModel
from typing import Optional

# Modèle décrivant les métadonnées stockées dans DynamoDB
class PhotoMetadata(BaseModel):
    photo_id: str
    original_filename: str
    s3_key: str
    file_size: int
    content_type: str
    upload_date: str # Format ISO-8601 UTC en String
    title: Optional[str] = None

# Modèle renvoyé au Frontend (Métadonnées + URL pré-signée S3)
class PhotoResponse(BaseModel):
    photo_id: str
    original_filename: str
    url: str
    file_size: int
    upload_date: str
    title: Optional[str] = None