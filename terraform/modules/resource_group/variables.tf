variable "azurerm_resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "bestrong-aks"
}

variable "azurerm_resource_group_location" {
  description = "The location of the Azure Resource Group"
  type        = string
  default     = "canadacentral"
}
