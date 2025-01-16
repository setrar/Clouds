# Define Resource Group
resource "azurerm_resource_group" "lab2_rg" {
  name     = "lab2"
  location = "East US"
}

# Define Service Plan
resource "azurerm_service_plan" "lab2_plan" {
  name                = "lab2-plan"
  location            = azurerm_resource_group.lab2_rg.location
  resource_group_name = azurerm_resource_group.lab2_rg.name
  os_type             = "Linux"          # Required OS type
  sku_name            = "B1"             # Specify the SKU name (e.g., B1 for Basic tier)
}

# Define Linux Web App for Python
resource "azurerm_linux_web_app" "lab2_app" {
  name                = "lab2-python-app"
  location            = azurerm_resource_group.lab2_rg.location
  resource_group_name = azurerm_resource_group.lab2_rg.name
  service_plan_id     = azurerm_service_plan.lab2_plan.id

  site_config {
    always_on          = true
    application_stack {
      python_version = "3.9" # Specify Python version
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python" # Specify runtime
    WEBSITE_RUN_FROM_PACKAGE = "1"     # Enable deployment from package
  }
}

