// Pins the Terraform version and the Azure plugin (provider) so the build
// behaves the same on every machine. "~> 4.0" allows 4.x updates but not 5.0.
// similarly terraform version allows 1.15.x
terraform {
  required_version = "~> 1.15.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }
  }

  // Remote state: the state file lives in the blob container we created,
  // not on the laptop. use_azuread_auth makes Terraform authenticate with
  // the az login session instead of a storage account key.
  backend "azurerm" {
    resource_group_name  = "rg-project4-ai-platform"
    storage_account_name = "stp4tfstateshreyas"
    container_name       = "tfstate"
    key                  = "project4.terraform.tfstate"
    use_azuread_auth     = true
  }
}

// azurerm 4.x requires the subscription ID explicitly. It comes from a
// variable so the ID is not hardcoded in a repo that will be public.
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

