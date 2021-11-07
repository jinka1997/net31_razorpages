resource "azurerm_container_group" "aci" {
  exposed_port        = [
    {
      port     = 80
      protocol = "TCP"
    },
  ]
  ip_address_type     = "Private"
  location            = azurerm_resource_group.rg.location
  name                = "${local.resource_name}-aci"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.rg.name
  network_profile_id  = azurerm_network_profile.profile.id
  restart_policy      = "OnFailure"
  tags                = {}
  container {
    commands                     = []
    cpu                          = 1
    environment_variables        = {}
    image                        = "${azurerm_container_registry.acr.login_server}/sampleweb:latest"
    memory                       = 1.5
    name                         = "${local.resource_name}-container"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }
  timeouts {}
}

resource "azurerm_network_profile" "profile" {
  name                = "${local.resource_name}-network-profile"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  container_network_interface {
    name = "${local.resource_name}-container-nic"

    ip_configuration {
      name      = "${local.resource_name}-ipconfig"
      subnet_id = azurerm_subnet.private1a.id
    }
  }
}