#### -----------------------
##   Blob Store Configuration
#### -----------------------

# Storage account
resource "azurerm_storage_account" "lab1-sa" {
  name                     = "blobstoreclouds2025eurbr"
  resource_group_name      = azurerm_resource_group.lab1.name
  location                 = azurerm_resource_group.lab1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "static_site" {
  storage_account_id = azurerm_storage_account.lab1-sa.id

  index_document = "index.html"
}


# Upload static HTML file
resource "azurerm_storage_blob" "html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.lab1-sa.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/index.html"
  content_type           = "text/html"

  depends_on = [azurerm_storage_account_static_website.static_site]
}


output "static_site_url" {
  value = azurerm_storage_account.lab1-sa.primary_web_endpoint
}

#### -----------------------
##   ACR Configuration
#### -----------------------

resource "azurerm_container_registry" "lab1-acr" {
  name                = "acrclouds2025eurbr"
  resource_group_name = azurerm_resource_group.lab1.name
  location            = azurerm_resource_group.lab1.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "acr_login_server" {
  value = azurerm_container_registry.lab1-acr.login_server
}
