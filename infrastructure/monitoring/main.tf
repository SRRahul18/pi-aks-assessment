resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.environment}-${var.prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = { environment = var.environment }
}