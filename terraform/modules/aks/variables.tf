variable "resource_group_name" {
  type        = string
  default     = "bestrong-aks"
  description = "Name of the resource group."
}

variable "resource_group_location" {
  type        = string
  default     = "canadacentral"
  description = "Location of the resource group."
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 2
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
}

variable "ssh_key_name" {
  description = "Name for the SSH key."
  type        = string
  default     = "bestrong-ssh-key"
}
