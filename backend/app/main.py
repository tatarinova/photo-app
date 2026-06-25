from fastapi import FastAPI, File, UploadFile

from fastapi.staticfiles import StaticFiles

from pathlib import Path


app = FastAPI()

UPLOAD_DIR = Path("uploads") #### WORKDIR/uploads/ (WORKDIR est defini dans Dockerfile)

UPLOAD_DIR.mkdir(exist_ok=True)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/")
def root():
    return {"message": "Photo Gallery API"}

@app.get("/health")
def health():
    return {"status": "ok"}

#### upload photos
@app.post("/photos")
async def upload_photo(file: UploadFile = File(...)):
    file_path = UPLOAD_DIR / file.filename

    with open(file_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)

    return {
        "filename": file.filename,
        "message": "uploaded"
    }

##### list photos
@app.get("/photos")
def list_photos():
    photos = []

    for file in UPLOAD_DIR.iterdir():
        if file.is_file():
            photos.append(file.name)

    return {
        "photos": photos
    }

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
    file_path = UPLOAD_DIR / filename

    if not file_path.exists():
        return {
            "message": "file not found"
        }

    file_path.unlink()  ### delete file

    return {
        "filename": filename,
        "message": "deleted"
    }