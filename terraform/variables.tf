variable "aws_region" {
  description = "AWS region"
  type = string
  default = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "my_ip" {
  description = "Public IP allowed to SSH (CIDR)"
  type        = string
}