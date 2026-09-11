services:
  backend:
    image: ${backend_repository}:latest

    expose:
      - "8000"

    environment:
      BUCKET_NAME: ${photos_bucket}

    restart: unless-stopped  

  frontend:
    image: ${frontend_repository}:latest

    ports:
      - "80:80"

    depends_on:
      - backend

    restart: unless-stopped