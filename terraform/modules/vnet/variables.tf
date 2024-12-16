variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
}

variable "azurerm_subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "bestrong-aks-subnet"
}