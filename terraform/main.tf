// A "data" block reads something that already exists instead of creating
// it. The resource group was made with the CLI (it holds the state storage),
// so Terraform only looks it up. This also means "terraform destroy" can
// never delete the group that holds its own state file.
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

// Tags applied to every resource so they are easy to find and filter in
// cost reports. Defined once here and reused with local.tags.
locals {
  tags = {
    project = "project4-ai-agent-platform"
    managed_by = "terraform"
  }
}