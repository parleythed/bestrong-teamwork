output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "The name of the storage container"
  value       = azurerm_storage_container.tfstate.name
}
