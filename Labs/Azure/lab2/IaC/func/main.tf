resource "azurerm_resource_group" "lab2" {
  name     = "lab2-function-rg"
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

resource "azurerm_linux_function_app" "lab2" {
  name                       = "clouds25lab2eurbrnifnc"
  location                   = azurerm_resource_group.lab2.location
  resource_group_name        = azurerm_resource_group.lab2.name
  service_plan_id            = azurerm_service_plan.lab2.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

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


}

resource "null_resource" "github_deployment" {
  provisioner "local-exec" {
    command = <<EOT
      # Wait for Func initialization
      echo "Waiting for Func initialization..."
      for i in {1..10}; do
        curl -s --head https://clouds25lab2eurbrnifnc.azurewebsites.net | grep "200 OK" && break || sleep 30
      done

      TMP_DIR=$(mktemp -d)
      cd $TMP_DIR

      # Download repository
      echo "Downloading repository..."
      curl -L https://github.com/setrar/CloudsNIFunction/archive/refs/heads/main.zip -o repo.zip
      unzip repo.zip
      mv CloudsNIFunction-main/* .
      rm -rf CloudsNIFunction-main repo.zip

      # Create zip and deploy with retries
      echo "Creating zip and starting deployment..."
      zip -r function_code.zip .
      for i in {1..3}; do
        az functionapp deployment source config-zip \
            --resource-group lab2-function-rg \
            --name clouds25lab2eurbrnifnc \
            --src function_code.zip && break || sleep 30
      done

      echo "Cleaning up temporary files..."
      rm -rf $TMP_DIR
    EOT
  }

  depends_on = [azurerm_linux_function_app.lab2]
}


