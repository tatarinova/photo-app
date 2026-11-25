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
- Exposes a Python backend API with FastAPI
- Stores uploaded photos in Amazon S3
- Automatically generates thumbnails with an AWS Lambda function
- Stores photo metadata in Amazon DynamoDB
- Runs the application in Docker containers on EC2 instances
- Uses an Auto Scaling Group with a minimum of 2 and a maximum of 4 EC2 instances
- Uses an Application Load Balancer in front of the EC2 instances
- Deploys application changes automatically with GitHub Actions
- Pushes new container images to Amazon ECR
