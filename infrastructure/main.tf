resource "azurerm_resource_group" "aks-rg" {
  name     = "rg-${var.environment}-${var.prefix}"
  location = var.location
  tags = { 
    environment = var.environment 
  }
}

locals {
  name_prefix = var.prefix
}

# networking
module "network" {
  source   = "./network"
  prefix   = local.name_prefix
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
}

# acr
module "acr" {
  source   = "./acr"
  prefix   = local.name_prefix
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  environment = var.environment
}

# monitoring
module "monitoring" {
  source   = "./monitoring"
  prefix   = local.name_prefix
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  environment = var.environment
}

# aks
module "aks" {
  source   = "./aks"
  prefix   = local.name_prefix
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  vnet_system_subnet_id = module.network.aks_system_subnet_id
  vnet_worker_subnet_id = module.network.aks_worker_subnet_id
  environment = var.environment
  acr_id = module.acr.acr_id
  log_analytics_workspace_id = module.monitoring.log_analytics_id
}