#### -----------------------
##   WebApp Configuration
#### -----------------------

# App Service Plan
resource "azurerm_service_plan" "lab1" {
  name                = "lab1-service-plan"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  os_type = "Windows" # Specify the operating system type (Windows/Linux)

  sku_name = "B1"      # Basic tier supports always_on
}

# Web App
resource "azurerm_windows_web_app" "lab1" {
  name                = "webappclouds2025eurbr"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  service_plan_id     = azurerm_service_plan.lab1.id

  site_config {
    always_on = true
  }

  app_settings = {
    "WEBSITE_USE_32BIT_WORKER_PROCESS" = "true"
    "FRAMEWORK_VERSION"               = "v3.5"
  }

  https_only = true
}


resource "null_resource" "github_deployment" {
  provisioner "local-exec" {
    command = <<EOT
      az webapp deployment source config --name webappclouds2025eurbr \
      --resource-group lab1-resources \
      --repo-url https://github.com/setrar/CloudsASPXContent \
      --branch main --manual-integration
    EOT
  }

  depends_on = [azurerm_windows_web_app.lab1] # Ensure Web App is created first
}


# Output Web App URL
output "web_app_url" {
  value = azurerm_windows_web_app.lab1.default_hostname
}

