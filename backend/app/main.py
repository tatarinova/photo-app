from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Photo Gallery API"}

@app.get("/health")
def health():
    return {"status": "ok"}
