output "shared_sql_database_connection_string" {
  value = "Server=tcp:${azurerm_sql_server.shared_sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.shared_sql_database.name};Persist Security Info=False;User ID=${azurerm_sql_server.shared_sql_server.administrator_login};Password=${azurerm_sql_server.shared_sql_server.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}