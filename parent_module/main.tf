terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "myvm" {
    source  = "./child_module"  
    vmcount = 2
    environ = "dev"
    location = "centralus"
    cidr = "10.0.0.0"
}

# output "azurerm_public_ip" {
#   value = module.myvm.azurerm_public_ip
# }

output "vm_public_ips" {
  value = module.myvm.public_ip_addresses
}
