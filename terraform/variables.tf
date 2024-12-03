variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "rg_location" {
  description = "Azure region for the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "ssh_username" {
  description = "Admin username for Linux nodes"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the AKS nodes"
  type        = string
}
