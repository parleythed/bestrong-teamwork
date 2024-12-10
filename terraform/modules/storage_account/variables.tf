variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "bestrong-aks"
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = "canadacentral"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "bestrongsaapi"
}

variable "container_name" {
  description = "The name of the storage container"
  type        = string
  default     = "tfstate"
}
