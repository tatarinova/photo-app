from fastapi import FastAPI, File, UploadFile

from pathlib import Path


app = FastAPI()

UPLOAD_DIR = Path("uploads") #### WORKDIR/uploads/ (WORKDIR est defini dans Dockerfile)

UPLOAD_DIR.mkdir(exist_ok=True)

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