terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
 
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = "dev-rg-1${count.index+1}"
  location = "centralindia"
  count=2
}