# Azure Storage Account
resource "azurerm_storage_account" "mapreduce_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.mapreduce.name
  location                 = azurerm_resource_group.mapreduce.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Azure Blob Storage Container
resource "azurerm_storage_container" "input_container" {
  name                  = "input-container"
  storage_account_name  = azurerm_storage_account.mapreduce_storage.name
  container_access_type = "private"
}

# Azure Service Plan
resource "azurerm_service_plan" "mapreduce_plan" {
  name                = "mapreduce-plan"
  resource_group_name = azurerm_resource_group.mapreduce.name
  location            = azurerm_resource_group.mapreduce.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Azure Linux Function App
resource "azurerm_linux_function_app" "mapreduce_function" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.mapreduce.name
  location                   = azurerm_resource_group.mapreduce.location
  service_plan_id            = azurerm_service_plan.mapreduce_plan.id
  storage_account_name       = azurerm_storage_account.mapreduce_storage.name
  storage_account_access_key = azurerm_storage_account.mapreduce_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}

# Outputs
output "function_app_url" {
  value = azurerm_linux_function_app.mapreduce_function.default_hostname
}

output "storage_account_name" {
  value = azurerm_storage_account.mapreduce_storage.name
}

output "storage_account_connection_string" {
  value     = azurerm_storage_account.mapreduce_storage.primary_connection_string
  sensitive = true
}


