
# Create Front Door
resource "azurerm_frontdoor" "shared_front_door" {
  name                                         = "fd-${var.name}-001"
  resource_group_name                          = var.shared_resource_group_name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "routing-rule"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["frontend-endpoint"]

    forwarding_configuration {
      forwarding_protocol                         = "MatchRequest"
      backend_pool_name                           = "backend-binding"
      cache_enabled                               = true
      cache_use_dynamic_compression               = true
      cache_query_parameter_strip_directive       = "StripNone"
    }
  }

  backend_pool_load_balancing {
    name = "load-balancing-settings"
  }

  backend_pool_health_probe {
    name = "health-probe-settings"
  }

  backend_pool {
    name = "backend-binding"

    dynamic "backend" {
      for_each = var.front_door_backend_endpoints

      content {
        host_header = backend.value["front_door_backend_host_header"]
        address     = backend.value["front_door_backend_address"]
        http_port   = 80
        https_port  = 443
      }
    }
    
    load_balancing_name = "load-balancing-settings"
    health_probe_name   = "health-probe-settings"
  }

  frontend_endpoint {
    name      = "frontend-endpoint"
    host_name = "fd-${var.name}-001.azurefd.net"
  }
}



# Store application insights key in key vault
resource "azurerm_key_vault_secret" "application_insights_key" {
  name         = "ApplicationInsights--InstrumentationKey"
  value        = var.application_insights_instrumentation_key
  key_vault_id = var.shared_key_vault_id
}

# Store sql server connection string in key vault
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "ConnectionStrings--SampleDataContext"
  value        = var.shared_sql_server_connection_string
  key_vault_id = var.shared_key_vault_id
}

# Store app configuration connection string in key vault
resource "azurerm_key_vault_secret" "app_configuration_connection_string" {
  name         = "AppConfig"
  value        = var.shared_app_configuration_connection_string
  key_vault_id = var.shared_key_vault_id
}