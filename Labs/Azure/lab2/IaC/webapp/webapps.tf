#### -----------------------
##   WebApp Configuration
#### -----------------------

# App Service Plan
resource "azurerm_service_plan" "lab2" {
  name                = "lab2-service-plan"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  os_type             = "Linux"          # Required OS type
  sku_name            = "S1"      # Basic tier supports always_on
}

# Define Linux Web App for Python
resource "azurerm_linux_web_app" "lab2" {
  name                = "webappclouds2025nibr"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  service_plan_id     = azurerm_service_plan.lab2.id

  site_config {
    always_on          = true
    application_stack {
      python_version = "3.9" # Specify Python version
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python" # Specify runtime
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"     # Enable deployment from package
  }

  https_only = true
  
  depends_on = [azurerm_service_plan.lab2]
}

resource "null_resource" "github_deployment" {
  provisioner "local-exec" {
    command = <<EOT
      # Wait for WebApp initialization
      echo "Waiting for WebApp initialization..."
      for i in {1..10}; do
        curl -s --head https://webappclouds2025nibr.azurewebsites.net | grep "200 OK" && break || sleep 15
      done

      TMP_DIR=$(mktemp -d)
      cd $TMP_DIR

      # Download repository
      echo "Downloading repository..."
      curl -L https://github.com/setrar/CloudsNumericalIntegration/archive/refs/heads/main.zip -o repo.zip
      unzip repo.zip
      mv CloudsNumericalIntegration-main/* .
      rm -rf CloudsNumericalIntegration-main repo.zip

      # Create zip and deploy with retries
      echo "Creating zip and starting deployment..."
      zip -r app.zip .
      for i in {1..3}; do
        az webapp deploy --resource-group lab2-resources \
          --name webappclouds2025nibr \
          --src-path app.zip --type zip && break || sleep 30
      done

      echo "Cleaning up temporary files..."
      rm -rf $TMP_DIR
    EOT
  }

  depends_on = [azurerm_linux_web_app.lab2]
}

# Output Web App URL
output "web_app_url" {
  value = azurerm_linux_web_app.lab2.default_hostname
}

