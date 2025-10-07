variable "prefix" {
  description = "Prefix used for naming AKS resources."
  type        = string
}

variable "location" {
  description = "Azure region for AKS cluster."
  type        = string
}

variable "vnet_system_subnet_id" {
  description = "Subnet ID where AKS nodes will be deployed."
  type        = string
}

variable "vnet_worker_subnet_id" {
  description = "Subnet ID for the worker nodes."
  type        = string
}

variable "acr_id" {
  description = "Azure Container Registry ID for granting pull access."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy AKS resources into."
  type        = string  
}

variable "environment" {
  description = "Environment for AKS resources."
  type        = string
  default     = "dev"  
}

variable "admin_group_object_id" {
  description = "Azure AD Group Object ID for AKS admin access."
  type        = string
  default = "2548533e-b16c-4379-aca4-6349cef180de"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for monitoring."
  type        = string  
}

variable "tenant_id" {
  description = "Azure AD Tenant ID."
  type        = string  
}