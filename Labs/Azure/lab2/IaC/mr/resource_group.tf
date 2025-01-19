

# Azure Resource Group
resource "azurerm_resource_group" "mapreduce" {
  name     = var.resource_group_name
  location = var.location
}


