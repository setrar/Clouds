resource "azurerm_resource_group" "lab1" {
  name     = "lab1-resources"
  location = "East US"
}

resource "azurerm_virtual_machine" "lab1" {
  name                  = "lab1-vm"
  location              = azurerm_resource_group.lab1.location
  resource_group_name   = azurerm_resource_group.lab1.name
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "lab1-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "lab1-vm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids = [
    azurerm_network_interface.lab1.id,
  ]
}

resource "azurerm_network_interface" "lab1" {
  name                = "lab1-nic"
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_network" "lab1" {
  name                = "lab1-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab1.location
  resource_group_name = azurerm_resource_group.lab1.name
}

resource "azurerm_subnet" "lab1" {
  name                 = "lab1-subnet"
  resource_group_name  = azurerm_resource_group.lab1.name
  virtual_network_name = azurerm_virtual_network.lab1.name
  address_prefixes     = ["10.0.2.0/24"]
}

