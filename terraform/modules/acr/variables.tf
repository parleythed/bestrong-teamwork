variable "azurerm_container_registry_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "role_definition_name" {
  description = "The name of the role to assign"
  type        = string
  default     = "Owner"
}

variable "principal_id" {
  description = "The principal ID to assign the role to"
  type        = string
}
