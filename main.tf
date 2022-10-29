terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.29.1"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
    version = "3.29.1"
    alias = "networking"
    subscription_id = var.subscription_id
    client_id = var.client_id 
    client_secret = var.client_secret
  
}

resource "azurerm_resource_group" "luftborntest" {
    name = "luftbormtest"
    location = "eastus"
  
}

resource "azurerm_virtual_network" "luftborntest" {
    name = "luftborntest-network"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.luftborntest.location
    resource_group_name = azurerm_resource_group.luftborntest.name
  
}

resource "azurerm_subnet" "luftborntest" {
    name = "internal"
    resource_group_name = azurerm_resource_group.luftborntest.name
    virtual_network_name = azurerm_virtual_network.luftborntest.name
    address_prefixes = ["10.0.2.0/24"]  
}
resource "azurem_public_ip" "public_ip" {
    name = "vm_public_ip"
    azurerm_resource_group = azurerm_resource_group.luftborntest.name
    location = azurerm_resource_group.luftborntest.location
    allocation_method = "Dynamic"
  
}

resource "azurerm_network_interface" "luftborntest" {
    name = "luftborntest-nic"
    location = azurerm_resource_group.luftborntest.location
    resource_group_name = azurerm_resource_group.luftborntest.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.luftborntest.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.public_ip.id
    }

  
}

resource "azurerm_network_security_group" "luftborntest" {

    name = "luftborntestNSG1"
    location = azurerm_resource_group.luftborntest.location
    resource_group_name = azurerm_resource_group.luftborntest.name
  
}

resource "azurem_network_security_rule" "luftborntest" {
    name = "luftborntestNSR1"
    priority = 100
    direction = "Inboud"
    access = "Allow"
    protocal = "Tcp"
    sourco_port_range = "*"
    destination_port_range = "22"
    sourco_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.luftborntest.name 
    azurerm_network_security_group = azurerm_network_security_group.luftborntest.name
  
}

resource "azurerm_network_interface_security_group_association" "luftborntest" {
    network_interface_id = azurerm_network_interface.luftborntest.id
    network_security_group_id = azurerm_network_security_group.luftborntest.id
  
}

resource "tls_private_key" "sshkey" {
    algorithm = "RSA"
    rsa_bits = 4096
  
}

resource "azurerm_linux_virtual_machine" "luftborntest" {
    name = "luftborntest-vm"
    resource_group_name = azurerm_resource_group.luftborntest.name
    location = azurerm_resource_group.luftborntest.location
    size = "Standard_B1s"
    admin_username = "root"
    disable_password_authentication = true

    network_interface_ids = [azurerm_network_interface.luftborntest.id]

    source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
      caching = "ReadWrite"
      storage_account_type = "standard_LRS"
    }

    admin_ssh_key {
      username = "root"
      public_key = tls_private_key.sshkey.public_key_openssh
    }

}

output "resource_group_name" {
  value = azurerm_resource_group.luftborntest.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.luftborntest.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

