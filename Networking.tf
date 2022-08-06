# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "hub-vnet-rg" {
    name     = var.hub-rg
    location = var.hub-location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "hub-vnet" {
  name                = "hub-ncus-vnet"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  location            = azurerm_resource_group.hub-vnet-rg.location
  address_space       = ["172.0.0.0/23"]

  tags = {
    environment = var.environment
    }
}

# Create Subnets for Hub Vnet
resource "azurerm_subnet" "hub-gw" {
    name                 = "gw"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes     = ["172.0.0.0/26"]
}

resource "azurerm_subnet" "hub-mgt" {
    name                 = "mgt"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["172.0.0.192/27"]
}

resource "azurerm_subnet" "hub-appgw" {
    name                 = "appgw"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["172.0.0.128/27"]
}

resource "azurerm_subnet" "hub-mon" {
    name                 = "mon"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["172.0.0.224/27"]
}

resource "azurerm_subnet" "hub-stg" {
    name                 = "stg"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["172.0.0.64/26"]
}


# Create Network Interface cards for Subnets
resource "azurerm_network_interface" "hub-mgt-nic" {
    name                 = "hub-mgt-nic"
    location             = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = var.environment
    subnet_id                     = azurerm_subnet.hub-mgt.id
    private_ip_address_allocation = "Dynamic"
    }

    tags = {
    environment = var.environment
    }
}
resource "azurerm_network_interface" "hub-gw-nic" {
    name                 = "hub-gw-nic"
    location             = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = var.environment
    subnet_id                     = azurerm_subnet.hub-gw.id
    private_ip_address_allocation = "Dynamic"
    }

    tags = {
    environment = var.environment
    }
}
resource "azurerm_network_interface" "hub-appgw-nic" {
    name                 = "hub-appgw-nic"
    location             = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = var.environment
    subnet_id                     = azurerm_subnet.hub-appgw.id
    private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = var.environment
    }
}

resource "azurerm_network_interface" "hub-stg-nic" {
    name                 = "hub-stg-nic"
    location             = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    enable_ip_forwarding = true

    ip_configuration {
    name                          = var.environment
    subnet_id                     = azurerm_subnet.hub-stg.id
    private_ip_address_allocation = "Dynamic"
    }

    tags = {
    environment = var.environment
    }
}

resource "azurerm_windows_virtual_machine" "mgt-vm" {
  name                = "mgt-vm"
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  location            = azurerm_resource_group.hub-vnet-rg.location
  size                = "Standard_A0"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd99"
  network_interface_ids = [
    azurerm_network_interface.hub-mgt-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}