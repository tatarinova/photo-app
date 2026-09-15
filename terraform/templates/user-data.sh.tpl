#!/bin/bash

set -e

exec > /var/log/user-data.log 2>&1

echo "===== User Data started ====="

####################################
# Update Ubuntu
####################################

apt-get update -y

####################################
# Install Docker
####################################

apt-get install -y docker.io unzip curl 

systemctl enable docker

systemctl start docker

####################################
# Install AWS CLI v2
####################################

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

unzip /tmp/awscliv2.zip -d /tmp

/tmp/aws/install --update

####################################
# Install Docker Compose
####################################

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker compose version

####################################
# Create application directory
####################################

mkdir -p /opt/photo-app

cd /opt/photo-app

####################################
# Download docker-compose.yml 
#################################### 
aws s3 cp \
s3://${config_bucket}/docker-compose.yml \
/opt/photo-app/docker-compose.yml

# ####################################
# # Download .env (pour plus tard)
# #################################### 
# aws s3 cp \
# s3://${config_bucket}/.env \
# /opt/photo-app/.env || true

####################################
# Restart Docker
####################################
systemctl restart docker

sleep 10  ### wait 10 s before docker login

####################################
# Login ECR 
#################################### 
aws ecr get-login-password \
--region ${aws_region} \
|
docker login \
--username AWS \
--password-stdin \
# $${frontend_repository%/*} 
${frontend_repository}

###################################
# Run app
###################################
# /!\ docker-compose.yml in /opt/photo-app/
docker compose -f /opt/photo-app/docker-compose.yml pull

docker compose -f /opt/photo-app/docker-compose.yml up -d


###################################
echo "===== User Data finished ====="