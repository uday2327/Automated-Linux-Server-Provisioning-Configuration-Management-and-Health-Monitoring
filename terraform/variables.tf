variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "aws-devops-sre"
}

variable "environment" {
  type    = string
  default = "portfolio"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "admin_cidr" {
  type        = string
  description = "Administrator IPv4 CIDR allowed to access SSH and monitoring ports."
  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must be a valid IPv4 CIDR and cannot be open to the entire internet."
  }
}

variable "ssh_public_key_path" {
  type        = string
  description = "Absolute or relative path to the SSH public key."
}

variable "web_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "monitoring_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "root_volume_size" {
  type    = number
  default = 20
  validation {
    condition     = var.root_volume_size >= 20
    error_message = "root_volume_size must be at least 20 GiB."
  }
}
