resource "azurerm_virtual_network" "vnet" {
  address_space         = [
    "10.20.0.0/16",
  ] 
  dns_servers           = [] 
  location              = azurerm_resource_group.rg.location
  name                  = "${local.resource_name}-vnet" 
  resource_group_name   = azurerm_resource_group.rg.name
  tags                  = {} 
  timeouts {}
}

resource "azurerm_subnet" "public1a" {
  address_prefixes                               = [
    "10.20.1.0/24",
  ]
  name                                           = "public1a" 
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  timeouts {}
}

resource "azurerm_subnet" "public1c" {
  address_prefixes                               = [
    "10.20.2.0/24",
  ]
  name                                           = "public1c" 
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  timeouts {}
}

resource "azurerm_subnet" "private1a" {
  address_prefixes                               = [
    "10.20.3.0/24",
  ] 
  name                                           = "private1a" 
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  timeouts {}
  delegation {
    name = "ACIDelegationService" 
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ] 
      name    = "Microsoft.ContainerInstance/containerGroups"
    }
  }
}

resource "azurerm_subnet" "private1c" {
  address_prefixes                               = [
    "10.20.4.0/24",
  ]
  name                                           = "private1c" 
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  timeouts {}
}