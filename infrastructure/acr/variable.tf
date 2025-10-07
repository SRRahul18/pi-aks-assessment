variable "prefix" {
  description = "Prefix used for naming ACR resources."
  type        = string
}

variable "location" {
  description = "Azure region for ACR."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for ACR."
  type        = string
}

variable "environment" {
  description = "Environment for ACR resources."
  type        = string
  default     = "dev"
}