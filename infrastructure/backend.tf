terraform {
  backend "azurerm" {
    resource_group_name  = "sr-assessment-backend-rg"
    storage_account_name = "srassessmenttfstate"
    container_name       = "tfstate"
    key                  = "devaks.tfstate"
  }
}