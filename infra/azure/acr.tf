resource "azurerm_container_registry" "acr" {
  admin_enabled                 = true # これをtrueにしないと、ACIからアクセスできない
  location                      = azurerm_resource_group.rg.location
  name                          = replace("${local.resource_name}", "-", "")
  network_rule_set              = [] 
  public_network_access_enabled = true 
  quarantine_policy_enabled     = false
  resource_group_name           = azurerm_resource_group.rg.name
  retention_policy              = [
    {
      days    = 7
      enabled = false
    },
  ] 
  sku                           = "Basic" 
  tags                          = {}
  trust_policy                  = [
    {
      enabled = false
    },
  ] 
  zone_redundancy_enabled       = false 
  timeouts {}
}