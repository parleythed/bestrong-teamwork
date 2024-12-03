terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.9.1"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}