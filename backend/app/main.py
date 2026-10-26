from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, status
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
from app.config import ADMIN_USERNAME, ADMIN_PASSWORD
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import secrets

app = FastAPI(root_path="/api")

security = HTTPBasic()

@app.get("/")
def root():
    return {"message": "Photo Gallery API"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/server")
def server():
    return {"hostname": socket.gethostname()}



def verify_admin(credentials: HTTPBasicCredentials = Depends(security)):
    """Vérifie le nom d'utilisateur et le mot de passe admin"""
    is_user_correct = secrets.compare_digest(credentials.username, ADMIN_USERNAME)
    is_pass_correct = secrets.compare_digest(credentials.password, ADMIN_PASSWORD)
    
    if not (is_user_correct and is_pass_correct):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Accès refusé : Identifiants administrateur incorrects",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

# 1. UPLOAD PHOTO  (protegé par le mot de passe)
@app.post("/photos", dependencies=[Depends(verify_admin)])
async def upload_photo(file: UploadFile = File(...)):
    # Génération d'un ID unique et d'une clé S3 propre
    photo_id = str(uuid.uuid4())
    s3_key = f"originals/{photo_id}_{file.filename}"
    upload_time = datetime.now().isoformat()
    
    # Sauvegarde du fichier binaire dans S3
    upload_file_to_s3(file.file, s3_key, file.content_type)

    # C'est Lambda qui va ecrire les meta donnees dans DynamoDB

    return {
        "photo_id": photo_id,
        "filename": file.filename,
        "message": "uploaded successfully"
    }


# 2. LIST PHOTOS (access publique)
# (Avantage DynamoDB : Récupération rapide + URL pré-signées)
@app.get("/photos")
def list_photos():
    # Lecture depuis DynamoDB au lieu de lister S3 (beaucoup plus rapide)
    items = list_all_photos_metadata()
    photos = []

    for item in items:
        # Génération dynamique des deux types d'URL S3 temporaires
        thumb_url = generate_presigned_url(item["thumbnail_s3_key"])
        orig_url = generate_presigned_url(item["original_s3_key"])

        photos.append({
            "photo_id": item["photo_id"],
            "filename": item["original_filename"],
            "upload_date": item.get("upload_date"),
            "thumbnail_url": thumb_url,
            "original_url": orig_url,
        })

    return {"photos": photos}


# 3. DELETE PHOTO (protegé par le mot de passe)
@app.delete("/photos/{photo_id}", dependencies=[Depends(verify_admin)])
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