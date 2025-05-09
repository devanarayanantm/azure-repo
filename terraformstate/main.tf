terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "dev-tfstate"
      storage_account_name = "devbackendtfstatehdwua"
      container_name       = "dev-tfstate-blob"
      key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "state-demo-secure" {
  name     = "devnstate-demo"
  location = "centralindia"
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "dev-tfstate"
  location = "central india"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "devbackendtfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "dev-tfstate-blob"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}