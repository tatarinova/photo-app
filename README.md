# Photo Gallery on AWS

A personal project to learn AWS and Terraform by building a photo gallery from scratch. 

## Overview 

Photo Gallery is a portfolio project that hosts a small website with photos on AWS.

The goal of this project is to:
- learn AWS services and Terraform
- practice Infrastructure as Code (IaC)
- build something that can also be shown as a professional portfolio project


The domain is registered on Namecheap.

The project is deployed on demand for demonstrations only. 
The infrastructure and the website are created with `terraform apply`, 
then removed with `terraform destroy` to avoid keeping AWS resources running permanently.

This project is still evolving, but the base architecture is already in place and functional.

## What it does

- Displays photos in a web gallery
- Exposes a Python backend API with **FastAPI**
- Stores uploaded photos in **Amazon S3**
- Automatically generates thumbnails with an **AWS Lambda** function
- Stores photo metadata in **Amazon DynamoDB**
- Runs the application in Docker containers on **EC2** instances
- Uses an **Auto Scaling Group** (ASG) with a minimum of 2 and a maximum of 4 EC2 instances
- Uses an **Application Load Balancer** (ALB) in front of the EC2 instances
- Deploys application changes automatically with **GitHub Actions**
- Pushes new container images to **Amazon ECR**
- Uses **IAM** roles, policies, and instance profiles with restricted permissions

## How it works

1. A new photo is uploaded to the S3 bucket (`originals/` folder).
2. The upload triggers a Lambda function.
3. The Lambda function generates a thumbnail.
4. The thumbnail is stored in the same bucket (`thumbnails/` folder).
5. The Lambda function also writes photo metadata into DynamoDB.
6. The frontend displays the gallery through the backend API.

Photos can be added in two ways:
- directly from the AWS S3 console
- through the Swagger API interface, protected by password authentication

## AWS & tools used

- **AWS**: EC2, Auto Scaling Group, ALB, S3, DynamoDB, Lambda, ECR, IAM
- **Infrastructure as Code**: Terraform
- **Containers**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **App code**: Python, FastAPI, HTML/CSS/JavaScript

## Infrastructure layout

The infrastructure is managed with Terraform and split into two parts:

- `stateful/` for permanent resources  
  - S3 buckets
  - DynamoDB
  - ECR

- `stateless/` for ephemeral resources  
  - ALB
  - Auto Scaling Group
  - EC2
  - IAM
  - networking resources

The project also uses a separate S3 config bucket to store:
- `docker-compose.yml`
- `.env`

This makes it possible to update app configuration without recreating EC2 instances.

## Project structure

```text
├── .github/workflows/
├── backend/          # FastAPI app
├── frontend/         # Web UI
├── lambda/           # AWS Lambda functions
└── terraform/aws/
    ├── stateful/     # S3 buckets, DynamoDB, ECR
    └── stateless/    # ALB, ASG, EC2, IAM, network, etc. 


## Next steps 

1. Add second Lambda to generate watermarks

2. Add a third Lambda for AI image tagging/recognition

3. Use DynamoDB data in the frontend

4. Add filtering buttons and improve gallery search