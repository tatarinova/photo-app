from fastapi import FastAPI, File, UploadFile, HTTPException
from app.s3 import upload_file_to_s3, generate_presigned_url, delete_file_from_s3
import socket
import uuid
from datetime import datetime
from app.dynamodb import (
                            save_photo_metadata,
                            get_photo_metadata,
                            list_all_photos_metadata,
                            delete_photo_metadata,
)

app = FastAPI(root_path="/api")


@app.get("/")
def root():
    return {"message": "Photo Gallery API"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/server")
def server():
    return {"hostname": socket.gethostname()}


# 1. UPLOAD PHOTO  #### sera utilisé plus tard
@app.post("/photos")
async def upload_photo(file: UploadFile = File(...)):
    # Génération d'un ID unique et d'une clé S3 propre
    photo_id = str(uuid.uuid4())
    s3_key = f"photos/{photo_id}_{file.filename}"
    upload_time = datetime.now().isoformat()
    
    # Étape A : Sauvegarde du fichier binaire dans S3
    upload_file_to_s3(file.file, s3_key, file.content_type)

    # Étape B : Sauvegarde des métadonnées dans DynamoDB
    metadata = {
        "photo_id": photo_id, # Clé primaire DynamoDB
        "original_filename": file.filename,
        "s3_key": s3_key,
        "content_type": file.content_type,
        "upload_date": upload_time,
    }
    save_photo_metadata(metadata) 

    return {
        "photo_id": photo_id,
        "filename": file.filename,
        "message": "uploaded successfully"
    }


# 2. LIST PHOTOS (Avantage DynamoDB : Récupération rapide + URL pré-signées)
@app.get("/photos")
def list_photos():
    # Lecture depuis DynamoDB au lieu de lister S3 (beaucoup plus rapide)
    items = list_all_photos_metadata()
    photos = []

    for item in items:
        # Génération dynamique de l'URL d'accès temporaire S3
        url = generate_presigned_url(item["s3_key"])
        photos.append({
            "photo_id": item["photo_id"],
            "filename": item["original_filename"],
            "upload_date": item.get("upload_date"),
            "url": url,
        })

    return {"photos": photos}


# 3. DELETE PHOTO #### sera utilisé plus tard
@app.delete("/photos/{photo_id}")
def delete_photo(photo_id: str):
    # Étape A : Récupérer les métadonnées pour connaître le s3_key
    item = get_photo_metadata(photo_id) 
    if not item:
        raise HTTPException(status_code=404, detail="Photo not found")

    # Étape B : Supprimer le fichier binaire de S3
    delete_file_from_s3(item["s3_key"])

    # Étape C : Supprimer l'entrée dans DynamoDB
    delete_photo_metadata(photo_id)

    return {"photo_id": photo_id, "message": "deleted successfully"}