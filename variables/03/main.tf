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

resource "azurerm_resource_group" "example" {
  name     = "${var.rgname}"
  location = "central us"
  tags     = var.tags
}

output "boolean_type" {
  value=var.boolean_type

}

output "list_type" {
  value=var.list_type
}

output "map_type" {
  value=var.map_type
}

output "object_type" {
  value=var.object_type
}

output "tuple_type" {
  value=var.tuple_type
}

output "set_example" {
  value=var.set_example
}

output "map_of_objects" {
  value=var.map_of_objects
}

output "list_of_objects" {
  value=var.list_of_objects
}

output "rgname" {
  value=var.rgname
}


output "tags" {
  value=var.tags
}