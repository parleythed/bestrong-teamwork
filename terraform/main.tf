# Resource Group Module
module "resource_group" {
  source                     = "./modules/resource_group"
  azurerm_resource_group_name = var.rg_name
  azurerm_resource_group_location = var.rg_location
}

# VNet Module
module "vnet" {
  source                  = "./modules/vnet"
  vnet_name               = var.vnet_name
  resource_group_name     = module.resource_group.rg_name
  resource_group_location = module.resource_group.rg_location
  azurerm_subnet_name     = var.subnet_name
}

# AKS Cluster Module
module "aks" {
  source                  = "./modules/aks"
  resource_group_name     = module.resource_group.rg_name
  resource_group_location = module.resource_group.rg_location
  vnet_subnet_id          = module.vnet.subnet_id
  node_count              = var.node_count
  username                = var.ssh_username
  ssh_public_key          = var.ssh_public_key
}

