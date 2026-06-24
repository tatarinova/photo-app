# Photo Gallery

Projet d'apprentissage AWS + Docker + FastAPI. 


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