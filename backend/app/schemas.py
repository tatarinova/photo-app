from pydantic import BaseModel
from typing import Optional

# Model describing metadata stored in DynamoDB
class PhotoMetadata(BaseModel):
    photo_id: str
    original_filename: str
    original_s3_key: str
    thumbnail_s3_key: str
    file_size: int
    content_type: str
    upload_date: str # ISO-8601 UTC string format
    title: Optional[str] = None

# Model returned to the Frontend (Metadata + S3 presigned URLs)
class PhotoResponse(BaseModel):
    photo_id: str
    original_filename: str
    original_url: str
    thumbnail_url: str
    file_size: int
    upload_date: str
    title: Optional[str] = None