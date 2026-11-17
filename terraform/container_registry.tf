// Private registry that stores the container images (web API, agent workers) the cluster pulls from.
// Basic is the cheapest SKU and has everything this project needs. The name must be globally unique,
// 5-50 characters, letters and numbers only (no hyphens).
// admin_enabled is off so access goes through Azure RBAC (AcrPull for the cluster, AcrPush for CI) ...
// instead of a shared username and password.
resource "azurerm_container_registry" "main" {
  name = "acrproject4shreyas"
  resource_group_name = data.azurerm_resource_group.main.name
  location = var.location
  sku = "Basic"
  admin_enabled = false
  tags = local.tags
}