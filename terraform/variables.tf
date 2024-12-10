variable "rg_name" {
  description = "Resource group name"
  type        = string
  default = "bestrong-aks"
}

variable "rg_location" {
  description = "Azure region for the resource group"
  type        = string
  default = "Canada Central"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default = "cluster-vnet"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default = "cluster-subnet"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "ssh_username" {
  description = "Admin username for Linux nodes"
  type        = string
  default     = "azureadmin"
}
variable "ssh_key_name" {
  description = "Name for the SSH key."
  type        = string
  default     = "bestrong-ssh-key"
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
