// The private network everything in Project 4 lives in. A /16 gives
// 65k addresses, far more than needed, but resizing a VNet later means
// rebuilding it, so the room is deliberate. 10.40.x.x is chosen to avoid
// overlapping with ranges used in earlier projects, which matters if
// the networks are ever peered.
resource "azurerm_virtual_network" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  name                = "vnet-project4"
  location            = var.location
  address_space       = ["10.40.0.0/16"]
  tags                = local.tags
}

// Where the AKS nodes will get their IPs. Each node takes one address
// from this subnet; pods get theirs from a separate overlay range, so a
// /24 (251 usable addresses) is plenty for a small cluster.
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.40.0.0/24"]
}

// Reserved for private endpoints (registry, storage, queue) so those
// services can be reached over the VNet instead of the public internet.
// Kept in its own subnet so NSG rules can treat it differently later.
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.40.1.0/24"]
}