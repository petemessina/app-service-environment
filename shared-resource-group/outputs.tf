output "shared_key_vault_id" {
  value = azurerm_key_vault.shared_key_vault.id
}

output "application_insights_id" {
  value = azurerm_application_insights.shared_application_insights.id
}

output "application_insights_name" {
  value = azurerm_application_insights.shared_application_insights.name
}

output "application_insights_instrumentation_key" {
  value = azurerm_application_insights.shared_application_insights.instrumentation_key
}

output "shared_resource_group_name" {
  value = azurerm_resource_group.shared_resource_group.name
}

output "shared_key_vault_name" {
  value = azurerm_key_vault.shared_key_vault.name
}

output "shared_key_vault_uri" {
  value = azurerm_key_vault.shared_key_vault.vault_uri
}

output "shared_app_configuration_connection_string" {
  value = azurerm_app_configuration.shared_app_configuration.primary_read_key.0.connection_string
}

output "shared_app_configuration_endpoint" {
  value = azurerm_app_configuration.shared_app_configuration.endpoint
}