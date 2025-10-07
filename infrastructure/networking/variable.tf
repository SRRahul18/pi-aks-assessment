variable "prefix" {
  description = "Prefix used for naming network resources."
  type        = string
}

variable "location" {
  description = "Azure region for network resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy network resources into."
  type        = string  
}

variable "environment" {
  description = "Environment for network resources."
  type        = string
  default     = "dev"  
}