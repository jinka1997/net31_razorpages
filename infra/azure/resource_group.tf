resource "azurerm_resource_group" "rg" {
  location = "japaneast" 
  name     = "${local.resource_name}-rg" 
  tags     = {} 
  timeouts {}
}