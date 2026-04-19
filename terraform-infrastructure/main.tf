resource "random_string" "suffix" {
  length    = 6
  lower     = true
  special   = false
  numeric   = true
  upper     = false
  min_upper = 0
}

resource "azurerm_resource_group" "resource-group" {
  name     = "rg-${var.application_name}-${var.environemnt_name}"
  location = var.primary_location
}

# for storage Docker image
resource "azurerm_container_registry" "container-registry" {
  name                = "cr${random_string.suffix.result}${var.environemnt_name}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  sku                 = "Basic"
}

# right not not 100% sure why I need this
# resource "azurerm_container_app_environment" "container-app-env" {
#   name                = "cea-${var.application_name}-${var.environemnt_name}"
#   location            = azurerm_resource_group.resource-group.location
#   resource_group_name = azurerm_resource_group.resource-group.name
# }
