output "container_registry_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "container_registry_admin_enabled" {
  description = "Indicates if admin access is enabled for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_enabled
}
