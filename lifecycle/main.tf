terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version=">=1.0"
}

provider "azurerm" {
  features {}
}

 
resource "azurerm_resource_group" "main" {
  name     = "devn-rg"
  location = "south india"
}
 
resource "azurerm_virtual_network" "vnet" {
  name                = "dev-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
 
resource "azurerm_subnet" "subnet" {
  name                 = "dev-Subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_public_ip" "public_ip" {
  name                = "dev-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "nic" {
  name                = "dev-NIC"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
 
  tags = {
    Name = "My NIC"
  }

}
 
resource "azurerm_linux_virtual_machine" "myvm" {
  name                = "dev-VM-${random_pet.vm_suffix.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myOsDisk-${random_pet.vm_suffix.id}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    Name = "My VM ${random_pet.vm_suffix.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}



# resource "azurerm_linux_virtual_machine" "myvm" {
#   name                = "dev-VM-${random_pet.vm_suffix.id}"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   size                = "Standard_B1s"
#   admin_username      = "azureuser"
#   network_interface_ids = [
#     azurerm_network_interface.nic.id
#   ]

#   admin_ssh_key {
#     username      = "azureuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#     name                 = "myOsDisk"
#   }
 
#   source_image_reference {
#   publisher = "Canonical"
#   offer     = "UbuntuServer"
#   sku       = "18_04-lts"
#   version   = "latest"
# }

 
 
#   tags = {
#     Name = "My Virtual Machine"
#     Env  = "Dev"
#   }

#   lifecycle {
# 	create_before_destroy = true
#   }
# }

resource "random_pet" "vm_suffix" {
  length = 2
}

