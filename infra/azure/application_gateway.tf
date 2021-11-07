locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
  gateway_ip_configuration_name  = "${azurerm_virtual_network.vnet.name}-gwipcfg"
}

resource "azurerm_application_gateway" "gateway" {
  enable_http2        = false
  location            = azurerm_resource_group.rg.location
  name                = "${local.resource_name}-gateway" 
  resource_group_name = azurerm_resource_group.rg.name
  tags                = {} 
  zones               = [] 
  backend_address_pool {
    ip_addresses = [
      azurerm_container_group.aci.ip_address,
    ] 
    name         = local.backend_address_pool_name
  }
  backend_http_settings {
    cookie_based_affinity               = "Disabled" 
    name                                = local.http_setting_name
    pick_host_name_from_backend_address = false 
    port                                = 80 
    protocol                            = "Http" 
    request_timeout                     = 20 
    trusted_root_certificate_names      = [] 
  }
  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    private_ip_address_allocation = "Dynamic" 
    public_ip_address_id          = azurerm_public_ip.gateway.id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80 
  }
  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.private1c.id
  }
  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    host_names                     = [] 
    name                           = local.listener_name
    protocol                       = "Http" 
    require_sni                    = false 
  }
  request_routing_rule {
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    http_listener_name         = local.listener_name
    name                       = local.request_routing_rule_name
    priority                   = 1
    rule_type                  = "Basic" 
  }
  sku {
    capacity = 1 
    name     = "Standard_v2" 
    tier     = "Standard_v2" 
  }
  timeouts {}
}

resource "azurerm_public_ip" "gateway" {
  allocation_method       = "Static"
  idle_timeout_in_minutes = 4 
  ip_tags                 = {} 
  ip_version              = "IPv4"
  location                = azurerm_resource_group.rg.location
  name                    = "${local.resource_name}-public-ip"
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = "Standard" 
  sku_tier                = "Regional" 
  tags                    = {} 
  timeouts {}
}
