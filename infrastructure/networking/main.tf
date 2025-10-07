resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.environment}-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "aks_system_subnet" {
  name                 = "subnet-system"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_worker_subnet" {
  name                 = "subnet-worker"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "aks_system_nsg" {
  name                = "subnet-aks-system-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_security_group" "aks_worker_nsg" {
  name                = "subnet-aks-worker-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = {
    environment = var.environment
  }
  
}
resource "azurerm_subnet_network_security_group_association" "aks_system" {
  subnet_id                 = azurerm_subnet.aks_system_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_system_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "aks_worker" {
  subnet_id                 = azurerm_subnet.aks_worker_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_worker_nsg.id
}