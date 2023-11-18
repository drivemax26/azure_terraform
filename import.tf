resource "azurerm_resource_group" "my_resource_group" {
  location = var.resource_group_location
  name     = var.resource_group_name
}
