# download Linux + NGINX
FROM nginx:alpine  

# copy frontend/* (sauf Dockerfile) vers /usr/share/nginx/html - dossier par default servi par NGINX
COPY . /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf