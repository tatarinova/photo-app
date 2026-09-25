variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
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

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "domain_name" {
  type = string
}

variable "alert_email" {
  description = "Email receiving CloudWatch/SNS alerts"
  type        = string
}