# Resource Group
resource "azurerm_resource_group" "lab1" {
  name     = "lab1-resources"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "lab1_vnet" {
  name                = "lab1-vnet"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "lab1_subnet" {
  name                 = "lab1-subnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.lab1_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "lab1_public_ip" {
  name                = "lab1-public-ip"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "lab1_nic" {
  name                = "lab1-nic"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab1_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab1_public_ip.id
  }
}

# Virtual Machine

resource "azurerm_linux_virtual_machine" "lab1_vm" {
  name                = "lab1-vm"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
  size                = var.vm_size  # Use variable here 
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/robert@eurecom.fr.pub") # Path to your SSH public key
  }

  network_interface_ids = [
    azurerm_network_interface.lab1_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Cloud-Init Script
  custom_data = filebase64("cloud-init.yaml")  # Automatically Base64-encodes the file

}

# Security Group
resource "azurerm_network_security_group" "lab1_nsg" {
  name                = "lab1-nsg"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "lab1_subnet_nsg" {
  subnet_id                 = azurerm_subnet.lab1_subnet.id
  network_security_group_id = azurerm_network_security_group.lab1_nsg.id
}

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

