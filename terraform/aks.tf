# The AKS cluster: Azure runs the control plane; we pay only for the node
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-project4"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = "aks-project4"
  sku_tier            = "Free"

  # One node, x64 (the quota we have). Pods are scheduled onto it.
  default_node_pool {
    name            = "system"
    vm_size         = "Standard_D2ps_v6"
    node_count      = 1
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.aks.id
  }

  # The cluster's own Azure identity; no passwords to manage
  identity {
    type = "SystemAssigned"
  }

  # Overlay: only the node takes an IP from the VNet; pods use a separate private range
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    service_cidr        = "10.100.0.0/16"
    dns_service_ip      = "10.100.0.10"
  }

  tags = {
    managed_by = "terraform"
    project    = "project4-ai-agent-platform"
  }
}

# Lets the node pull images from our registry (replaces `kind load`)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}