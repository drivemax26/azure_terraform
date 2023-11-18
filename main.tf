
resource "azurerm_resource_group" "my_rg" {
  name     = "${var.resource_group_name_prefix}-${var.resource_group_name}"
  location = var.resource_group_location
}


resource "azurerm_virtual_network" "my_virtual_network" {
  name                = "${var.resource_group_name_prefix}-${var.azurerm_virtual_network_name}"
  address_space       = var.vnet_range
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
}


resource "azurerm_subnet" "my_subnet" {
  name                 = var.azurerm_subnet_name
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_virtual_network.name
  address_prefixes     = var.subnet_range
}


resource "azurerm_network_interface" "main" {
  name                = "${var.resource_group_name_prefix}-main"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = var.computer_name
  location              = azurerm_resource_group.my_rg.location
  resource_group_name   = azurerm_resource_group.my_rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.azurerm_vm_size
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }

  storage_os_disk {
    name              = "myosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.storage_account_type
  }

  os_profile {
    computer_name  = var.computer_name
    admin_username = var.user_name
    admin_password = "Password1234!"

    custom_data = <<-EOF
#!bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install apache2 -y

sudo systemctl enable apache2
sudo systemctl start apache2

echo "Welcome to Azure!" > /var/www/html/index.html
EOF
    
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
 
}


resource "azurerm_public_ip" "myPublicIP" {
  name                = var.azurerm_public_ip
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  allocation_method   = "Dynamic"

  
}


resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location               = azurerm_resource_group.my_rg.location
  resource_group_name    = azurerm_resource_group.my_rg.name

security_rule {
    name                       = "my_rulen"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}