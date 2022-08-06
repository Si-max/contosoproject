resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "North Central US"
}

resource "azurerm_virtual_wan" "example" {
  name                = "example-vwan"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_virtual_hub" "example" {
  name                = "example-hub"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  virtual_wan_id      = azurerm_virtual_wan.example.id
  address_prefix      = "10.0.0.0/24"
}

resource "azurerm_vpn_gateway" "example" {
  name                = "example-vpng"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  virtual_hub_id      = azurerm_virtual_hub.example.id
}

resource "azurerm_vpn_site" "example" {
  name                = "example-vpn-site"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  virtual_wan_id      = azurerm_virtual_wan.example.id
  link {
    name       = "link1"
    ip_address = "10.1.0.0"
  }
  link {
    name       = "link2"
    ip_address = "10.2.0.0"
  }
}

resource "azurerm_vpn_gateway_connection" "example" {
  name               = "example"
  vpn_gateway_id     = azurerm_vpn_gateway.example.id
  remote_vpn_site_id = azurerm_vpn_site.example.id

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.example.link[0].id
  }

  vpn_link {
    name             = "link2"
    vpn_site_link_id = azurerm_vpn_site.example.link[1].id
  }
}