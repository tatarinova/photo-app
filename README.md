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

