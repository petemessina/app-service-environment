output "api_host_name" {
  value = azurerm_app_service.api_tier_application_service.default_site_hostname
}