output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "aks_system_subnet_id" {
  value = azurerm_subnet.aks_system_subnet.id
}

output "aks_worker_subnet_id" {
  value = azurerm_subnet.aks_worker_subnet.id
}