terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  name                = "bestrong-aks-cluster" 
  dns_prefix          = "bestrong-aks-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_B2s"
    node_count = var.node_count
  }

  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
