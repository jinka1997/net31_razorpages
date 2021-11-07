resource "azurerm_app_service_plan" "plan" {
  is_xenon                     = false 
  kind                         = "linux" 
  location                     = azurerm_resource_group.rg.location
  maximum_elastic_worker_count = 1 
  #maximum_number_of_workers    = 3 
  name                         = "${local.resource_name}-plan" 
  per_site_scaling             = false 
  reserved                     = true 
  resource_group_name          = azurerm_resource_group.rg.name
  tags                         = {} 
  zone_redundant               = false 
  sku {
    capacity = 1
    size     = "B1" 
    tier     = "Basic" 
  }
  timeouts {}
}

resource "azurerm_app_service" "app" {
  app_service_plan_id               = azurerm_app_service_plan.plan.id
  app_settings                      = {
    "DOCKER_ENABLE_CI"                    = "true"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.acr.admin_password
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.acr.admin_username
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  } 
  client_affinity_enabled           = false
  client_cert_enabled               = false
  enabled                           = true 
  https_only                        = false
  location                          = azurerm_resource_group.rg.location 
  name                              = "${local.resource_name}-app"
  resource_group_name               = azurerm_resource_group.rg.name
  tags                              = {} 
  auth_settings {
    additional_login_params        = {} 
    allowed_external_redirect_urls = [] 
    enabled                        = false 
    token_refresh_extension_hours  = 0 
    token_store_enabled            = false 
  }
  logs {
    detailed_error_messages_enabled = false 
    failed_request_tracing_enabled  = false 
    application_logs {
      file_system_level = "Off" 
    }
  }
  site_config {
    acr_use_managed_identity_credentials = false 
    always_on                            = false 
    default_documents                    = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html",
    ] 
    dotnet_framework_version             = "v4.0" 
    ftps_state                           = "AllAllowed" 
    http2_enabled                        = false 
    ip_restriction                       = [] 
    linux_fx_version                     = "DOCKER|${azurerm_container_registry.acr.login_server}/sampleweb:latest" 
    local_mysql_enabled                  = false 
    managed_pipeline_mode                = "Integrated" 
    min_tls_version                      = "1.2" 
    number_of_workers                    = 1 
    remote_debugging_enabled             = false 
    remote_debugging_version             = "VS2019" 
    scm_ip_restriction                   = [] 
    scm_use_main_ip_restriction          = false 
    use_32_bit_worker_process            = true 
    vnet_route_all_enabled               = false 
    websockets_enabled                   = false 
  }
  timeouts {}
}