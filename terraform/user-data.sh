#!/bin/bash
set -e

apt-get update -y

apt-get install -y \
    docker.io \
    docker-compose-v2 \
    unzip \
    curl

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu