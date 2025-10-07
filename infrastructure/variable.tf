variable "prefix" {
  description = "Prefix used for naming backend resources."
  type        = string
}

variable "location" {
  description = "Azure region for backend storage account."
  type        = string
}

variable "environment" {
  description = "Environment for backend resources."
  type        = string
  default     = "dev"
}

variable "container_name" {
  description = "Storage container name for Terraform state."
  type        = string
  default     = "tfstate"
}