# Create a resource group
resource "azurerm_resource_group" "shared_resource_group" {
  name     = "rg-shared-${var.name}-001"
  location = var.resource_location
}

# Create application insights
resource "azurerm_application_insights" "shared_application_insights" {
  name                = "appi-${var.name}"
  location            = azurerm_resource_group.shared_resource_group.location
  resource_group_name = azurerm_resource_group.shared_resource_group.name
  application_type    = "web"
}

# Create key vault
resource "azurerm_key_vault" "shared_key_vault" {
  name                        = "kv-${var.name}-001"
  location                    = azurerm_resource_group.shared_resource_group.location
  resource_group_name         = azurerm_resource_group.shared_resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
      "purge",
      "recover"
    ]
  }
}

# Create private dashboard
#resource "azurerm_dashboard" "application-dashboard" {
#  name                  = "dash-${var.name}-001"
#  resource_group_name   = azurerm_resource_group.shared_resource_group.name
#  location              = azurerm_resource_group.shared_resource_group.location
#  dashboard_properties = templatefile("${path.module}/application-dashboard.tpl",
#    {
#      subscription_id             = var.subscription_id
#      shared_resource_group_name  = azurerm_resource_group.shared_resource_group.name
#      application_insights_name   = azurerm_application_insights.shared_application_insights.name
#  })
#}

# Create App Configuration
resource "azurerm_app_configuration" "shared_app_configuration" {
  name                = "appcs-${var.name}-001"
  resource_group_name = azurerm_resource_group.shared_resource_group.name
  location            = azurerm_resource_group.shared_resource_group.location
}

# Create Log Analytics
#resource "azurerm_log_analytics_workspace" "example" {
#  name                = "log-${var.name}-001"
#  resource_group_name = azurerm_resource_group.shared_resource_group.name
#  location            = azurerm_resource_group.shared_resource_group.location
#  sku                 = "PerGB2018"
#  retention_in_days   = 30
#}