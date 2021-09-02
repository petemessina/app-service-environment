locals {
  resource-name                 = "${var.application_name}-${var.environment}"
  primary_resource_location     = "Norway East"
  resource_locations            = ["Norway East", "East US"]
}

terraform {
  backend "azurerm" {
    resource_group_name   = "rg-region-testing-001"
    storage_account_name  = "stregiontesting"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# Create shared resources
module shared_resource_group {
  source            = "./shared-resource-group"

  name              = local.resource-name
  resource_location = local.primary_resource_location
  subscription_id   = data.azurerm_client_config.current.subscription_id
  tenant_id         = data.azurerm_client_config.current.tenant_id
  object_id         = data.azurerm_client_config.current.object_id
}

# Create api tier
module api_tier_resource_group {
  for_each = toset(local.resource_locations)
  
  source                            = "./api-tier-resource-group"

  name                              = local.resource-name
  resource_location                 = each.value
  resource_number                   = index(local.resource_locations, each.value) + 1
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  key_vault_id                      = module.shared_resource_group.shared_key_vault_id
  application_insights_id           = module.shared_resource_group.application_insights_id
  shared_resource_group_name        = module.shared_resource_group.shared_resource_group_name
  key_vault_name                    = module.shared_resource_group.shared_key_vault_name
  health_check_endpoint             = "healthcheck"
  shared_resource_group_location    = local.primary_resource_location

  application_settings = {
    Endpoints--AppConfig        = module.shared_resource_group.shared_app_configuration_endpoint
    VaultUri                    = module.shared_resource_group.shared_key_vault_uri
  }
}

# Create main web tier
module web_tier_resource_group {
  for_each = toset(local.resource_locations)

  source                            = "./web-tier-resource-group"

  name                              = local.resource-name
  resource_location                 = each.value
  resource_number                   = index(local.resource_locations, each.value) + 1
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  key_vault_id                      = module.shared_resource_group.shared_key_vault_id
  application_insights_id           = module.shared_resource_group.application_insights_id
  shared_resource_group_name        = module.shared_resource_group.shared_resource_group_name
  key_vault_name                    = module.shared_resource_group.shared_key_vault_name
  shared_resource_group_location    = local.primary_resource_location

  application_settings = {
    api_url                     = "https://${module.api_tier_resource_group[each.value].api_host_name}/"
    application_location        = each.value
    Endpoints--AppConfig        = module.shared_resource_group.shared_app_configuration_endpoint
    VaultUri                    = module.shared_resource_group.shared_key_vault_uri
  }
}

# Create main data tier
#module data_tier_resource_group {
#  source                            = "./data-tier-resource-group"

#  name                              = local.resource-name
#  resource_location                 = local.primary_resource_location
#  sql_administrator_login           = var.sql_administrator_login
#  sql_administrator_password        = var.sql_administrator_password
#}

# Create Global Resources
module global_resources {
    source                                      = "./global-resources"

    name                                        = local.resource-name
    resource_location                           = local.primary_resource_location
    shared_resource_group_name                  = module.shared_resource_group.shared_resource_group_name
    shared_application_insights_name            = module.shared_resource_group.application_insights_name
    application_insights_instrumentation_key    = module.shared_resource_group.application_insights_instrumentation_key
    shared_key_vault_id                         = module.shared_resource_group.shared_key_vault_id
    shared_sql_server_connection_string         = module.data_tier_resource_group.shared_sql_database_connection_string
    shared_app_configuration_connection_string  = module.shared_resource_group.shared_app_configuration_connection_string

    front_door_backend_endpoints = [
      for resource_location in local.resource_locations : {
        front_door_backend_host_header  = module.web_tier_resource_group[resource_location].default_site_host_name
        front_door_backend_address      = module.web_tier_resource_group[resource_location].default_site_host_name
      }
    ]
}