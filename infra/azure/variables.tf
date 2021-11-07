locals {
    environment = "develop"
    app_name = "netcore31-razor"

    resource_name = "${local.app_name}-${local.environment}"
}

