locals {
  resource_number    = format("%03d", var.resource_number)
}

# Create a resource group
resource "azurerm_resource_group" "api_tier_resource_group" {
  name     = "rg-api-${var.name}-${local.resource_number}"
  location = var.resource_location
}

# Create service plan
resource "azurerm_app_service_plan" "api_tier_service_plan" {
  name                = "plan-${var.name}-${local.resource_number}"
  location            = azurerm_resource_group.api_tier_resource_group.location
  resource_group_name = azurerm_resource_group.api_tier_resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create application service
resource "azurerm_app_service" "api_tier_application_service" {
  name                = "api-${var.name}-${local.resource_number}"
  location            = azurerm_resource_group.api_tier_resource_group.location
  resource_group_name = azurerm_resource_group.api_tier_resource_group.name
  app_service_plan_id = azurerm_app_service_plan.api_tier_service_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    dotnet_framework_version = "v5.0"
    scm_type                 = "LocalGit"
  }

  app_settings = merge({ KeyVaultName = var.key_vault_name }, var.application_settings)
}

# Register SMI with key vault
resource "azurerm_key_vault_access_policy" "api_tier_system_identity_key_vault_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_app_service.api_tier_application_service.identity[0].principal_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Build in api test for 200 success
resource "azurerm_application_insights_web_test" "application_insights_api_test" {
  name                    = "tf-test-appinsights-apitest-${local.resource_number}"
  location                = var.shared_resource_group_location
  resource_group_name     = var.shared_resource_group_name
  application_insights_id = var.application_insights_id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 60
  enabled                 = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr"]

  configuration = <<XML
<WebTest xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Name="my-apitest" Id="${var.apiTestId}" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
   <Items>
      <Request Method="GET" Guid="${var.apiTestId}" Version="1.1" Url="https://${azurerm_app_service.api_tier_application_service.default_site_hostname}/${var.health_check_endpoint}" ThinkTime="0" Timeout="120" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
   </Items>
</WebTest>
XML

}