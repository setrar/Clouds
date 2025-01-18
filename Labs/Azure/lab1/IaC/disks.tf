# Standard SSD Disk
resource "azurerm_managed_disk" "standard_ssd_disk" {
  name                 = "standard-ssd-disk"
  location             = azurerm_resource_group.lab1.location
  resource_group_name  = azurerm_resource_group.lab1.name
  storage_account_type = "StandardSSD_LRS"
  disk_size_gb         = 50
  create_option        = "Empty"  # Required argument
}

# Premium SSD Disk
resource "azurerm_managed_disk" "premium_ssd_disk" {
  name                 = "premium-ssd-disk"
  location             = azurerm_resource_group.lab1.location
  resource_group_name  = azurerm_resource_group.lab1.name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 50
  create_option        = "Empty"  # Required argument
}

