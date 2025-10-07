variable "prefix" {
  description = "Prefix used for naming monitoring resources."
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy monitoring resources into."
  type        = string  
}

variable "environment" {
  description = "Environment for monitoring resources."
  type        = string
  default     = "dev"  
}