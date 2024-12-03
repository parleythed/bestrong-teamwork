variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "bestrong-aks-vnet"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "bestrong-aks"
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
  default     = "canadacentral" 
}

variable "azurerm_subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "bestrong-aks-subnet"
}