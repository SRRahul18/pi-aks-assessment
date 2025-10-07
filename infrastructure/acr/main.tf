resource "azurerm_container_registry" "acr" {
  name                = lower(replace("acr${var.environment}${var.prefix}acr", "-", ""))
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  tags = { 
    environment =  var.environment 
  }
  anonymous_pull_enabled = false
  quarantine_policy_enabled = true
  public_network_access_enabled = false
}