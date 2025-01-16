resource "azurerm_resource_group" "lab2" {
  name     = "lab2-resources"
  location = "East US"
}

resource "azurerm_virtual_machine" "lab2" {
  name                  = "lab2-vm"
  location              = azurerm_resource_group.lab2.location
  resource_group_name   = azurerm_resource_group.lab2.name
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "lab2-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "lab2-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids = [
    azurerm_network_interface.lab2.id,
  ]
}

resource "azurerm_network_interface" "lab2" {
  name                = "lab2-nic"
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_network" "lab2" {
  name                = "lab2-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab2.location
  resource_group_name = azurerm_resource_group.lab2.name
}

resource "azurerm_subnet" "lab2" {
  name                 = "lab2-subnet"
  resource_group_name  = azurerm_resource_group.lab2.name
  virtual_network_name = azurerm_virtual_network.lab2.name
  address_prefixes     = ["10.0.2.0/24"]
}

