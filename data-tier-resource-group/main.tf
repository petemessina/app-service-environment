# Create a resource group
resource "azurerm_resource_group" "data_resource_group" {
  name     = "rg-data-${var.name}-001"
  location = var.resource_location
}

# Create SQL Server
resource "azurerm_sql_server" "shared_sql_server" {
  name                         = "sql-${var.name}"
  resource_group_name          = azurerm_resource_group.data_resource_group.name
  location                     = azurerm_resource_group.data_resource_group.location
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_password
  version                      = "12.0"
}

# Create SQL Database
resource "azurerm_sql_database" "shared_sql_database" {
  name                = "sqld-${var.name}-001"
  resource_group_name = azurerm_resource_group.data_resource_group.name
  location            = azurerm_resource_group.data_resource_group.location
  server_name         = azurerm_sql_server.shared_sql_server.name
}

# Allow Azure Services to Connect
resource "azurerm_sql_firewall_rule" "Azure_servicessql_firewall_rule" {
  name                = "AzureServicesFirewallRule"
  resource_group_name = azurerm_resource_group.data_resource_group.name
  server_name         = azurerm_sql_server.shared_sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}