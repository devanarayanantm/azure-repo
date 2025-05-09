terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Variables
variable "server_config" {
  description = "Configuration for the Azure Virtual Machines"

  type = map(object({
    os_type   = string
    publisher = string
    offer     = string
    sku       = string
    vm_size   = string
  }))

  default = {
    "dev-web-server-a" = {
      os_type   = "Ubuntu"
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      vm_size   = "Standard_DS1_v2"
    },
    "dev-app-server-b" = {
      os_type   = "Windows"
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      vm_size   = "Standard_DS2_v2"
    }
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "dev-myResourceGroup1"
}

variable "location" {
  description = "Location for the resources"
  type        = string
  default     = "South India"
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "dev-myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "dev-mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Public IPs
resource "azurerm_public_ip" "public_ip" {
  for_each = var.server_config

  name                = "${each.key}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Network Interfaces
resource "azurerm_network_interface" "nic" {
  for_each = var.server_config

  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }
}

# Linux VMs
resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each = {
    for k, v in var.server_config : k => v if lower(v.os_type) == "linux" || lower(v.os_type) == "ubuntu"
  }

  name                            = each.key
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = each.value.vm_size
  admin_username                  = "myadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = "latest"
  }
}

# Windows VMs
resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each = {
    for k, v in var.server_config : k => v if lower(v.os_type) == "windows"
  }

  name                = each.key
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = each.value.vm_size
  admin_username      = "myadmin"
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = "latest"
  }
}
