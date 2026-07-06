from fastapi import FastAPI, File, UploadFile

from fastapi.middleware.cors import CORSMiddleware

from app.s3 import s3, BUCKET_NAME

import socket

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

#### upload photos
@app.post("/photos")
async def upload_photo(file: UploadFile = File(...)):
    
    s3.upload_fileobj(
                        file.file,
                        BUCKET_NAME,
                        file.filename,
                    )

    return {
        "filename": file.filename,
        "message": "uploaded"
    }

##### list photos
@app.get("/photos")
def list_photos():

    photos = []

    response = s3.list_objects_v2(Bucket=BUCKET_NAME)

    for obj in response.get("Contents", []):

        url = s3.generate_presigned_url(
                                        "get_object",
                                        Params={
                                            "Bucket": BUCKET_NAME,
                                            "Key": obj["Key"],
                                        },
                                        ExpiresIn=3600,
                                        )

        photos.append(
                        {
                            "filename": obj["Key"],
                            "url": url,
                        }
                    )

    return { "photos": photos }

### ou 
# @app.get("/photos")
# def list_photos():
#     return {
#         "photos": [
#             file.name
#             for file in UPLOAD_DIR.iterdir()
#             if file.is_file()
#         ]
#     }

@app.delete("/photos/{filename}")
def delete_photo(filename: str):
    
    s3.delete_object(
        Bucket=BUCKET_NAME,
        Key=filename,
    )

    return {
        "filename": filename,
        "message": "deleted"
    }