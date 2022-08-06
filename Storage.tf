resource "azurerm_resource_group" "hub-vnet-rg" {
  name     = "hub-ncus-net-rg"
  location = "northcentralus"
}

resource "azurerm_storage_account" "hub-stg-rg" {
  name                     = "hubncusstg"
  resource_group_name      = azurerm_resource_group.hub-vnet-rg.name
  location                 = azurerm_resource_group.hub-vnet-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "hub-stg-rg" {
  name                  = "hubncusstg"
  resource_group_name   = "${azurerm_resource_group.hub-vnet-rg.name}"
  storage_account_name  = "${azurerm_storage_account.hub-stg-rg.name}"
  container_access_type = "private"
}
