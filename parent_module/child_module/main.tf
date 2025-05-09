resource "azurerm_resource_group" "example" {
  name     = "devan-${terraform.workspace}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "dev-network"
  address_space       = ["${var.cidr}/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
 
resource "azurerm_subnet" "example" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["${var.cidr}/24"]
}
 
resource "azurerm_public_ip" "public_ip" {
  count               = var.vmcount
  name                = "dev-public-ip-${count.index}${var.environ}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method = "Static"
}
 
resource "azurerm_network_interface" "example" {
  count               = var.vmcount
  name                = "dev-nic-${count.index}${var.environ}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}
 
resource "azurerm_linux_virtual_machine" "example" {
  count               = var.vmcount
  name                = "dev-machine${count.index}${var.environ}"   #count.index???
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]
 
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
 
  tags = {
    Name = "dev"
  }
}

# output "azurerm_public_ip" {
#   value = azurerm_public_ip.public_ip
# }

output "public_ip_addresses" {
  value       = azurerm_public_ip.public_ip[*].ip_address
  # value       = [for ip in azurerm_public_ip.public_ip : ip.ip_address]
}