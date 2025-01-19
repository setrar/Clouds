terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "lab2_vnet" {
  name                = "lab2-vnet"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "lab2_subnet" {
  name                 = "lab2-subnet"
  resource_group_name  = azurerm_resource_group.lab2.name
  virtual_network_name = azurerm_virtual_network.lab2_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_machine_scale_set" "lab2_vmss" {
  name                = "lab2-vmss"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  sku                 = "Standard_D2s_v3"
  instances           = 2

  upgrade_policy {
    mode = "Manual"
  }

  admin_username = "azureuser"
  admin_password = "P@ssword1234!" # Replace with secure options in production

  os_profile {
    computer_name_prefix = "lab2vm"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    custom_data = base64encode(file("cloud-init.yaml")) # Optional
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    os_disk_size_gb   = 30
  }

  network_profile {
    name    = "lab2-nic"
    primary = true

    ip_configuration {
      name      = "lab2-ipconfig"
      subnet_id = azurerm_subnet.lab2_subnet.id
    }
  }
}

resource "azurerm_lb" "lab2_lb" {
  name                = "lab2-lb"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "lab2-lb-ipconfig"
    private_ip_address   = "10.0.1.4"
    private_ip_address_allocation = "Static"
  }
}

