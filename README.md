# Photo Gallery

Projet d'apprentissage AWS + Docker + FastAPI. 

## Venv et dependances

Creer la venv : uv venv 
    .venv/ 
          - sera ignoré par le git
          - seulement pour le dev local
          - ne sera pas envoyé sur AWS

Activer la venv sous Windows : .venv\Scripts\activate.bat

Generer uv.lock : uv lock

Ajouter de nouveaux modules : uv add AAA BBB CCC
                              uv add fastapi uvicorn python-multipart
                               ---> MAJ dans : uv.lock + pyproject.toml 

Lister toutes les dependances : uv pip list 

## Lancer l'appli en local  

uv run uvicorn app.main:app --reload

Go to : http://127.0.0.1:8000
        http://127.0.0.1:8000/health            status 
        http://127.0.0.1:8000/docs              SWAGGER interface pour tester les endpoints

## Lancer/Arreter/Modifier/Relancer l'appli dans Docker

(Lancer DockerDesktop avant.)

docker compose build

docker compose up

docker compose down

(modifs...)

docker compose up --build

## Conncter a EC2 : 

cd C:\Users\natal\Documents\RABOTA\AWS

ssh -i "photo-app-key.pem" ubuntu@<public DNS>

## Find IPv4 : 
PowerShell> curl -4 ifconfig.me 

(CIDR IPv4 : X.X.X.X/32)

OR 
go to : https://ifconfig.me
Mais chez moi, FireFox affiche IPv6

OR 

go to : https://www.monip.org/


## Generer lambda_function.zip (sous Windows pour Linux): 
cd lambda/

(Remove-Item -Recurse -Force .\temp_package -ErrorAction SilentlyContinue)
(Remove-Item -Force .\lambda_function.zip -ErrorAction SilentlyContinue)

mkdir temp_package

python -m pip install --isolated Pillow==10.4.0 --platform manylinux2014_x86_64 --target .\temp_package --implementation cp --python-version 3.9 --only-binary=:all: --force-reinstall --no-user 

Copy-Item gen_photo_miniatures.py -Destination .\temp_package\

Compress-Archive -Path .\temp_package\* -DestinationPath .\lambda_function.zip -Force

Remove-Item -Recurse -Force .\temp_package