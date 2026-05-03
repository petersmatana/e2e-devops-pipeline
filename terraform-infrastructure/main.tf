resource "random_string" "suffix" {
  length    = 6
  lower     = true
  special   = false
  numeric   = true
  upper     = false
  min_upper = 0
}

resource "azurerm_resource_provider_registration" "registration" {
  name = "Microsoft.App"
}

resource "azurerm_resource_group" "resource-group" {
  name     = "rg-${var.application_name}-${var.environemnt_name}"
  location = var.primary_location
}

resource "azurerm_user_assigned_identity" "container-app-identity" {
  name                = "id-${var.application_name}-${var.environemnt_name}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
}

resource "azurerm_role_assignment" "acr-pull" {
  scope                = azurerm_container_registry.container-registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container-app-identity.principal_id
}

# for storage Docker image
resource "azurerm_container_registry" "container-registry" {
  name                = "cr${random_string.suffix.result}${var.environemnt_name}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  sku                 = "Basic"
}

# TODO right not not 100% sure why I need this
resource "azurerm_container_app_environment" "container-app-env" {
  name                = "cea-${var.application_name}-${var.environemnt_name}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  depends_on          = [azurerm_resource_provider_registration.registration]
}

resource "azurerm_container_app" "container-app" {
  name                         = "ca-${var.application_name}-${var.environemnt_name}"
  container_app_environment_id = azurerm_container_app_environment.container-app-env.id
  resource_group_name          = azurerm_resource_group.resource-group.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container-app-identity.id]
  }

  registry {
    server   = azurerm_container_registry.container-registry.login_server
    identity = azurerm_user_assigned_identity.container-app-identity.id
  }

  template {
    container {
      name = "my-app"
      #       image  = "${azurerm_container_registry.container-registry.login_server}/my-app:latest"
      # image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      image  = "crnco8uadev.azurecr.io/my-app:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  lifecycle {
    ignore_changes = [template, registry]
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [azurerm_role_assignment.acr-pull]
}
