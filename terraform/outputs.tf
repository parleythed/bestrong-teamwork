output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.vnet.subnet_id
}


