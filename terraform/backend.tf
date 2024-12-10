terraform {
  backend "azurerm" {
    resource_group_name  = "bestrong-aks"
    storage_account_name = "bestrongsaapi"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
