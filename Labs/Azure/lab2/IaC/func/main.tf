resource "azurerm_resource_group" "lab2" {
  name     = "lab2-function-lab2"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "clouds25lab2eurbrstg"
  resource_group_name      = azurerm_resource_group.lab2.name
  location                 = azurerm_resource_group.lab2.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "lab2" {
  name                = "clouds25lab2eurbrsvcpln"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  os_type             = "Linux"
  sku_name            = "B1"  # Basic tier supports always_on
}

resource "azurerm_linux_function_app" "function" {
  name                       = "clouds25lab2eurbrniapp"
  location                   = azurerm_resource_group.lab2.location
  resource_group_name        = azurerm_resource_group.lab2.name
  service_plan_id            = azurerm_service_plan.lab2.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  site_config {
    always_on = true  # Optional but recommended for production environments
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
  }
}

